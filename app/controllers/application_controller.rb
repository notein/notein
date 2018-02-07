class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  
  def debug(str)
    logger.debug "-----------------------"
    logger.debug str
    logger.debug "-----------------------"
  end
  
  def after_sign_in_path_for(resource_or_scope)
    if current_user.reset_recover_token == 1
      current_user.authentication_token = nil
      current_user.recover_message = 1
      current_user.reset_recover_token = 0
      current_user.save    
    end
    "/#{current_user.username}"
  end
  
end
