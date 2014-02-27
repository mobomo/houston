module Configuration
  module Mailer
    def self.configured?
      !!(from && scheduler_email && host && port && user_name && password)
    end

    def self.settings=(hash)
      AppSettings.mailer_smtp_host      = hash[:host]
      AppSettings.mailer_smtp_port      = hash[:port]
      AppSettings.mailer_smtp_user_name = hash[:user_name]
      AppSettings.mailer_smtp_password  = hash[:password]
      AppSettings.mailer_smtp_from      = hash[:from]
      AppSettings.mailer_smtp_scheduler_email = hash[:scheduler_email]
      configure_mailer
    end

    # @return [String]
    def self.from
      AppSettings.mailer_smtp_from
    end

    # @return [String]
    def self.scheduler_email
      AppSettings.mailer_smtp_scheduler_email
    end

    # @return [String]
    def self.host
      AppSettings.mailer_smtp_host
    end

    # @return [String]
    def self.port
      AppSettings.mailer_smtp_port
    end

    # @return [String]
    def self.user_name
      AppSettings.mailer_smtp_user_name
    end

    # @return [String]
    def self.password
      AppSettings.mailer_smtp_password
    end

    def self.configure_mailer
      return unless configured?

      WeeklySchedule::Application.configure do
        config.action_mailer.delivery_method = :smtp
        config.action_mailer.smtp_settings = {
          address:        ::Configuration::Mailer.host,
          port:           ::Configuration::Mailer.port,
          user_name:      ::Configuration::Mailer.user_name,
          password:       ::Configuration::Mailer.password,
          authentication: 'plain',
          enable_starttls_auto: true,
        }
        config.action_mailer.default_url_options = {
          host: ::Configuration::Mailer.host
        }
      end
    end
  end
end
