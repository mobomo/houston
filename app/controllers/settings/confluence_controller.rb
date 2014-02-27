class Settings::ConfluenceController < Settings::Base
  def edit
    @settings = AppSettings.confluence.try(:[], Rails.env.to_sym) || {}
  end

  def update
    if params[:confluence].blank?
      redirect_to settings_edit_confluence_path,
        alert: 'Confluence settings are required'
    else
      AppSettings.confluence = {Rails.env.to_sym => params[:confluence].symbolize_keys}
      ::Configuration::Confluence.connect()
      redirect_to settings_path,
        notice: 'Confluence Settings Updated'
    end
  end
end