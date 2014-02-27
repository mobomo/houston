class Settings::MailSettingsController < Settings::Base
  def update
    if params_missing?
      redirect_to settings_edit_mail_settings_path,
        notice: 'All SMTP settings are required'
    else
      ::Configuration::Mailer.settings = {
        host:      params[:host],
        port:      params[:port],
        user_name: params[:user_name],
        password:  params[:password],
        from:      params[:from],
        scheduler_email: params[:scheduler_email],
      }
      redirect_to settings_edit_mail_settings_path,
        notice: 'Mail Settings Updated'
    end
  end

  def update_auto_mail
    AppSettings.auto_mail = params[:auto_mail] == 'on' ? 'on' : 'off'
    redirect_to :back
  end

  private

  def params_missing?
    expected = [:host, :port, :user_name, :password, :from, :scheduler_email]
    expected.any? { |key| params[key].blank? }
  end
end
