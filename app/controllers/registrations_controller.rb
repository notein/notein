class RegistrationsController < Devise::RegistrationsController
  before_action :configure_permitted_parameters
  skip_before_action :verify_authenticity_token, only: [:create]
  
  layout 'devise'
  
  def new
    super
  end

  def create
    super
  end

  def update
    super
  end
  
  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up) do |user_params|
      user_params.permit(:password, :username)
    end
    devise_parameter_sanitizer.permit(:account_update, keys: [:email])
  end
  
  def after_sign_up_path_for(resource)
    "/#{@user.username}/new"
  end
end