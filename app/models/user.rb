class User < ApplicationRecord
  acts_as_token_authenticatable
  
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable
  
  validates :username,
    :presence => true,
    :uniqueness => {
    :case_sensitive => false
  }
  
  validates :email, uniqueness: true, allow_blank: true

  validates_format_of :username, with: /^[a-zA-Z0-9_\.]*$/, :multiline => true
  
  before_create :set_avatar_color

  has_many :memos
  
  acts_as_tagger
  acts_as_follower
  acts_as_followable
  
  def email_required?
    false
  end

  def email_changed?
    false
  end
  
  def will_save_change_to_email?
    false
  end
  
  def avatar
    self.avatar_color
  end
  

  def self.find_first_by_auth_conditions(warden_conditions)
    conditions = warden_conditions.dup
    if login = conditions.delete(:login)
      where(conditions).where(["lower(username) = :value OR lower(email) = :value", { :value => login.downcase }]).first
    else
      if conditions[:username].nil?
        where(conditions).first
      else
        where(username: conditions[:username]).first
      end
    end
  end
  
  private
  
  def set_avatar_color
    self.avatar_color = (0..2).map{"%0x" % (rand * 0x80 + 0x80)}.join
  end
  

end
