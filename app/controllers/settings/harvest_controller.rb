class Settings::HarvestController < Settings::Base
  def update
    if params[:identifier].blank? || params[:secret].blank?
      redirect_to settings_edit_harvest_path,
        alert: 'Identifier and secret are required'
    else
      AppSettings.harvest_identifier = params[:identifier]
      AppSettings.harvest_secret     = params[:secret]
      redirect_to settings_edit_harvest_path,
        notice: 'Harvest Settings Updated'
    end
  end

  def refresh_token
    expires_at = Time.at(env['omniauth.auth']['credentials']['expires_at'])
    current_user.update_attributes({
      harvest_token: env['omniauth.auth']['credentials']['token'],
      harvest_refresh_token: env['omniauth.auth']['credentials']['refresh_token'],
      expires_at: (expires_at + 30.days),
      refresh_at: expires_at
    })
    redirect_to :edit_harvest_path
  end
end