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
        @memos = Memo.where("content like ? and public in (0,1)", "%#{params[:term]}%").joins(:user).order(updated_at: :desc)
      else
        @memos = Memo.where("content like ? and public = 1", "%#{params[:term]}%").joins(:user).order(updated_at: :desc)
      end
    end
    all_related_tags = @memos.collect{|memo|memo.tags}.flatten.uniq    
    @related_tags = all_related_tags.select{|tag|tag unless build_tag_list(params[:term], nil).include?(tag.name)}    
  end
  
  def tags
    @tag_list = Tag.where("name like ?", "#{params[:query]}%").order(taggings_count: :desc).collect{|t|t.name}
    respond_to do |format|
      format.json { render json: @tag_list }
    end
  end
  
  def users
    @user_list = User.where("username like ?", "#{params[:query]}%").collect{|u|u.username}
    respond_to do |format|
      format.json { render json: @user_list }
    end
  end
  
  def emoji
    q = params[:query]
    @emoji_list = Emoji.all.map(&:aliases).flatten.select{|e|e if e[0, q.size] == params[:query]}.first(10)
    @emoji_list.map! {|e| [e, Emoji.find_by_alias(e).raw]}
    
    respond_to do |format|
      format.json { render json: @emoji_list }
    end
  end  

end
