class ApplicationController < ActionController::Base
  protect_from_forgery

  helper_method :current_user
  
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

  def expire_report_page_caches
    expire_page pnl_reports_path
    expire_page inout_reports_path
    expire_page day_reports_path
    expire_page exposure_reports_path
  end
end
