class PasswordsController < Devise::PasswordsController
   
  def new
    super
  end 
  
  def create
    user = User.find_by_username(params[:user][:username])
    if user && user.email.blank?
      redirect_to "/users/token?user_username=#{params[:user][:username]}"
    else
      super
    end
  end
    
  def edit
    super
  end
  
  def update
    super
  end
      
end