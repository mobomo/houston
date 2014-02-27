class Settings::GoogleController < Settings::Base
  def update
    if params[:app_settings][:google_client_id].blank? || params[:app_settings][:google_client_secret].blank?
      redirect_to settings_edit_google_path,
        alert: 'Google OAuth settings are required'
    else
      AppSettings.google_client_id = params[:app_settings][:google_client_id]
      AppSettings.google_client_secret = params[:app_settings][:google_client_secret]
      User.where(role: 'SuperAdmin').map { |u| u.update_attribute(:logged_in, nil) }
      redirect_to settings_path,
        notice: 'Google OAuth Settings Updated'
    end
  end
end