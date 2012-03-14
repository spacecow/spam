class ApplicationController < ActionController::Base
  include BasicApplicationController
  protect_from_forgery

  helper_method :jt, :current_user, :pl
end
