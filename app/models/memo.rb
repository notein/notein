class Memo < ApplicationRecord
  acts_as_taggable
  
  auto_increment :url_id, scope: [:user_id]

  belongs_to :user
end
