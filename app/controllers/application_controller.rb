class ApplicationController < ActionController::Base
  include BasicApplicationController
  protect_from_forgery

  helper_method :jt, :current_user, :pl, :current_userid, :error

  rescue_from CanCan::AccessDenied do |exception|
    exception.default_message = alertify(:unauthorized_access)
    flash[:alert] = exception.message
    if current_user
      redirect_to welcome_url
    else
      session[:original_url] = request.path  
      redirect_to login_url
    end
  end

  def current_userid; current_user.userid end
  def current_password; session_password end

  private

    def session_password(*opt)
      if opt.present? 
        session[:password] = opt.first 
      else
        session[:password] 
      end
    end
end
