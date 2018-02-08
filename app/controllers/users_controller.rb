class UsersController < ApplicationController
  before_action :set_user, only: [:edit, :update, :destroy]
  
  acts_as_token_authentication_handler_for User, only: [:recover], fallback: :devise  
  
  layout "devise", only: [:token, :recover]

  # GET /users
  # GET /users.json
  def index
    @users = User.all
  end

  # GET /users/1
  # GET /users/1.json
  def show
    if params[:username]
      @user = User.find_by_username(params[:username])
      if @user && (@user == current_user)
        @memos = @user.memos.order(updated_at: :desc)
        @tags = @memos.tag_counts_on(:tags)
      elsif @user
        @memos = @user.memos.where("public = ?", 1).order(updated_at: :desc)
        @tags = @memos.tag_counts_on(:tags)
      else
        respond_to do |format|
          format.html { redirect_to "/" }
        end        
      end
    end
  end

  # GET /users/new
  def new
    @user = User.new
  end

  # GET /users/1/edit
  def edit
  end

  # POST /users
  # POST /users.json
  def create
    @user = User.new(user_params)

    respond_to do |format|
      if @user.save
        format.html { redirect_to @user, notice: 'User was successfully created.' }
        format.json { render :show, status: :created, location: @user }
      else
        format.html { render :new }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /users/1
  # PATCH/PUT /users/1.json
  def update
    respond_to do |format|
      if @user.update(user_params)
        format.html { redirect_to @user, notice: 'User was successfully updated.' }
        format.json { render :show, status: :ok, location: @user }
      else
        format.html { render :edit }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /users/1
  # DELETE /users/1.json
  def destroy
    @user.destroy
    respond_to do |format|
      format.html { redirect_to users_url, notice: 'User was successfully destroyed.' }
      format.json { head :no_content }
    end
  end
  
  def tag_cloud
    @tags = Post.tag_counts_on(:tags)
  end
  
  
  def token
  end
  
  def recover
    if current_user
      @new_pass = Devise.friendly_token.first(10)
      current_user.reset_password(@new_pass, @new_pass)
      current_user.reset_recover_token = 1
      current_user.save!
    else
      redirect_to "/users/password/new"
    end
  end
  
  def recover_message
    if current_user
      current_user.recover_message = 0
      current_user.save
      redirect_to "/#{current_user.username}"
    end
  end
  
  private
    # Use callbacks to share common setup or constraints between actions.
    def set_user
      @user = User.find_by_username(params[:username])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def user_params
      params.require(:user).permit(:username, :email)
    end
end
