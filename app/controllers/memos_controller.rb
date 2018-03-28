class MemosController < ApplicationController
  require 'rinku'
    
  before_action :set_memo, only: [:edit, :update, :destroy]
  
  before_action :authenticate_user!, only: [:new, :edit, :update, :destroy]
  
  # GET /memos/1
  # GET /memos/1.json
  def show
    @user = User.find_by(username: params[:username])
    @memo = Memo.find_by(url_id: params[:id], user_id: @user.id)
    if @memo && (@memo.public == 0 and @memo.user != current_user)
      redirect_to "/sorry"
    elsif @memo.blank?
      redirect_to "/sorry"
    end
  end

  # GET /memos/new
  def new
    @memo = Memo.new
  end

  # GET /memos/1/edit
  def edit
    @user = User.find_by(username: params[:username])
  end

  # POST /memos
  # POST /memos.json
  def create
    author = User.find_by_username(params[:username])
    unless memo_params[:content].blank? and author.nil?
      @memo = Memo.new(memo_params)
      @memo.public = 0 if params[:commit] == "Save private"
      @memo.user = author
      respond_to do |format|
        if @memo.save
          update_tags(@memo, current_user)
          format.html { redirect_to "/#{current_user.username}" }
          format.json { render :show, status: :created, location: @memo }
        else
          format.html { render :new }
          format.json { render json: @memo.errors, status: :unprocessable_entity }
        end
      end
    else
      redirect_to "/#{current_user.username}"
    end
  end

  # PATCH/PUT /memos/1
  # PATCH/PUT /memos/1.json
  def update
    params[:memo][:public] = "1" if params[:commit] == "Make public"
    respond_to do |format|
      if @memo.update(memo_params)
        update_tags(@memo, current_user)
        format.html { redirect_to "/#{current_user.username}" }
        format.json { render :show, status: :ok, location: @memo }
      else
        format.html { render :edit }
        format.json { render json: @memo.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /memos/1
  # DELETE /memos/1.json
  def destroy
    @memo.destroy
    respond_to do |format|
      format.html { redirect_to "/#{current_user.username}" }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_memo
      redirect_to "/" if !current_user.nil? && current_user.username != params[:username]
      @memo = Memo.find_by(url_id: params[:id], user_id: current_user.id) if current_user
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def memo_params
      params.require(:memo).permit(:title, :content, :user_id, :name, :tag_list, :public)
    end
    
    def update_tags(memo, user)
      tags = memo.content.scan(/#([A-Za-z0-9]+)/).flatten
      downcased_tags = tags.map{|x|x.downcase}
      memo.tags.delete_all
      user.tag(memo, with: downcased_tags, on: :tags)
      tags.each do |tag|
        memo.content.gsub!(" #" + tag, " <a href='/tags/" + tag.downcase + "'>#" + tag + "</a>")
      end
      # auto linking
      memo.content = Rinku.auto_link(memo.content, :all)
      memo.save 
    end
end
