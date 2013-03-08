class ApplicationController < ActionController::Base
  protect_from_forgery

  helper_method :current_user
  
  before_filter :require_user, :only => [:create, :destroy]

  private

  def current_user
    @current_user ||= User.find(session[:user_id]) if session[:user_id]
  end

  def require_user
    unless current_user
      flash[:notice] = "You must be logged in to access this page"
      redirect_to log_in_path
      return false
    end
  end

end
