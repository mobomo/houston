class SettingsController < ApplicationController
  before_filter :authenticate_user!, except: [:setup, :mode]
  before_filter :setup_completed?, only: :setup

  def setup
    @config = DashboardConfig.new(params[:config_form])

    if request.post? && @config.save
      AppSettings.mode = 'normal'
      redirect_to root_path, alert: 'Setup completed!'
    end
  end

  def mode
    if params[:to] == 'demo' && Import.last.nil? && AppSettings.mode.nil?
      AppSettings.mode = 'demo'

      AppSettings.confluence = {
        Rails.env.to_sym => {
          url: "https://intridea.atlassian.net/wiki/rpc/soap-axis/confluenceservice-v2?wsdl",
          user: "public.user",
          password: "publicuser123",
          space: "HOUSTON",
          faq_parent: "41975830",
          faq_link: "https://intridea.atlassian.net/wiki/display/HOUSTON/Houston+Demo+Home" }
      }
      ::Configuration::Confluence.connect()

      DemoImporter.new.import
      Schedule.reload_schedules
      session[:user_id] = Schedule.all.map(&:user_id).sample

      redirect_to root_path
    else
      redirect_to root_path, alert: 'Failed to switch to demo mode.'
    end
  end

  def user
    if AppSettings.mode == 'demo' && u = User.find_by_name(params[:name])
      session[:user_id] = u.id
    end

    redirect_to root_path
  end

  def index
  end

  def update_harvest
    expires_at = Time.at(env['omniauth.auth']['credentials']['expires_at'])
    current_user.update_attributes({
      harvest_token: env['omniauth.auth']['credentials']['token'],
      harvest_refresh_token: env['omniauth.auth']['credentials']['refresh_token'],
      expires_at: (expires_at + 30.days),
      refresh_at: expires_at
    })
    redirect_to '/settings/harvest'
  end

  private

  def setup_completed?
    if ::Configuration::GoogleOmniauth.configured? && User.configured?
      redirect_to root_url, alert: "Access denied"
    end
  end

end
