class ApplicationController < ActionController::Base
  protect_from_forgery

  helper_method :current_year
  helper_method :current_user
  helper_method :user_signed_in?
  helper_method :correct_user?

  private

  def current_user
    begin
      @current_user ||= User.find(session[:user_id]) if session[:user_id]
    rescue
      nil
    end
  end

  def user_signed_in?
    return true if current_user
  end

  def correct_user?
    @user = User.find(params[:id])
    unless current_user == @user
      redirect_to root_url, alert: "Access denied"
    end
  end

  def authenticate_user!
    if !current_user
      if ::Configuration::GoogleOmniauth.configured?
        redirect_to signin_url, alert: 'You need to sign in to access this page'
      elsif AppSettings.mode == 'demo'
        session[:user_id] = Schedule.all.map(&:user_id).sample
        redirect_to root_path
      else
        redirect_to setup_url
      end
    end
  end

  def current_year
    @current_year ||= Time.now.year
  end

end
