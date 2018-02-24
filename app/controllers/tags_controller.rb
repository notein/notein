class TagsController < ApplicationController
  include ApplicationHelper

  # GET /
  def show
    @user = User.find_by_username(params[:username])
    if @user and params[:tag] and params[:tags]
      @memos = Memo.tagged_with(build_tag_list(params[:tag], params[:tags]), match_all: false).where(user_id: @user.id, public: is_public(current_user, @user)).order(updated_at: :desc)
    elsif @user and params[:tag]
      @memos = Memo.tagged_with(params[:tag]).where(user_id: @user.id, public: is_public(current_user, @user)).order(updated_at: :desc)
    elsif params[:tag] and params[:tags]
      @memos = Memo.tagged_with(build_tag_list(params[:tag], params[:tags]), match_all: false).where(public: is_public(current_user, @user)).order(updated_at: :desc)
    elsif params[:tag]
      @memos = Memo.tagged_with(params[:tag]).where(public: is_public(current_user, @user)).order(updated_at: :desc)
    end
    
    all_related_tags = @memos.collect{|memo|memo.tags}.flatten.uniq    
    @related_tags = all_related_tags.select{|tag|tag unless build_tag_list(params[:tag], params[:tags]).include?(tag.name)}    
  end

  def is_public(current_user, profile_user)
    if current_user.nil? or profile_user.nil?
      return 1
    elsif !current_user.nil? and !profile_user.nil?
      if current_user == profile_user
        return [0,1]
      else
        return 1
      end      
    else 
      return 1      
    end
  end
  
end
