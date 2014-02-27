require 'omniauth-harvest/strategies/harvest'

Rails.application.config.middleware.use OmniAuth::Builder do
  provider :google_oauth2, setup: Configuration::GoogleOmniauth.setup_proc if AppSettings.table_exists?
  provider :harvest, ENV['HARVEST_IDENTIFIER'], ENV['HARVEST_SECRET']
end

# uncommented the following if you want to see the failure page rather than exception on development mode
OmniAuth.config.on_failure = Proc.new { |env|
  OmniAuth::FailureEndpoint.new(env).redirect_to_failure
}
