class Settings::AppSettingsController < Settings::Base
  def update
    if params[:app_settings].blank?
      redirect_to settings_edit_app_settings_path,
        alert: 'Application settings are required'
    else
      AppSettings.google_analytics_tracker = params[:app_settings][:google_analytics_tracker]
      AppSettings.dashboard_api_key = params[:app_settings][:dashboard_api_key]
      AppSettings.feedback_url = params[:app_settings][:feedback_url]
      redirect_to settings_path,
        notice: 'Application Settings Updated'
    end
  end
end