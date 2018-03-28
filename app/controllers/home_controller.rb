class HomeController < ApplicationController
    
  # GET /
  def index
    @memos = Memo.all.where(public: 1).order(updated_at: :desc)
    @tags = @memos.tag_counts_on(:tags).to_a.shuffle
  end
  
  def sorry
  end

  # GET /terms
  def terms
  end

  # GET /privacy
  def privacy
  end
  
  private
 
  def resource_name
    :user
  end
  helper_method :resource_name
 
  def resource
    @resource ||= User.new
  end
  helper_method :resource
 
  def devise_mapping
    @devise_mapping ||= Devise.mappings[:user]
  end
  helper_method :devise_mapping
 
  def resource_class
    User
  end
  helper_method :resource_class
  
end
