module Configuration
  class GoogleOmniauth
    class << self
      def configured?
        !!AppSettings.google_client_id && !! AppSettings.google_client_secret
      end
      
      def setup_proc
        lambda do |env|
          env['omniauth.strategy'].options[:client_id] = AppSettings.google_client_id
          env['omniauth.strategy'].options[:client_secret] = AppSettings.google_client_secret
          env['omniauth.strategy'].options[:authorize_options] = {approval_prompt: ''}
        end
      end
    end
  end
end