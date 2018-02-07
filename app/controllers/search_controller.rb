class SearchController < ApplicationController
  include ApplicationHelper

  # GET /
  def show
    @user = User.find_by_username(params[:username])
    
    if @user and params[:term] 
      if current_user == @user
        @memos = @user.memos.where("content like ?  and public in (0,1)", "%#{params[:term]}%").joins(:user).order(updated_at: :desc)
      else
        @memos = @user.memos.where("content like ? and public is 1", "%#{params[:term]}%").joins(:user).order(updated_at: :desc)  
      end
    elsif @user.nil? and params[:term]
      if !current_user.nil? and (current_user == @user)
        @memos = Memo.where("content like ? and public is [0,1]", "%#{params[:term]}%").joins(:user).order(updated_at: :desc)
      else
        @memos = Memo.where("content like ? and public is 1", "%#{params[:term]}%").joins(:user).order(updated_at: :desc)
      end
    end
    all_related_tags = @memos.collect{|memo|memo.tags}.flatten.uniq    
    @related_tags = all_related_tags.select{|tag|tag unless build_tag_list(params[:term], nil).include?(tag.name)}    
  end

end
