module Configuration
  module Confluence
    mattr_accessor :client
    def self.configured?
      !!settings && !!self.client
    end

    def self.settings
      return unless AppSettings.confluence
      AppSettings.confluence[Rails.env.to_sym]
    end

    def self.connect
      self.client =
        if Rails.env.test?
          nil
        elsif !!settings
          begin
            ConfluenceSoap.new(settings[:url], settings[:user],settings[:password],
                               ::Confluence::Options)
          rescue Exception => e
            puts 'Failed to connect to confluence: ' + e.message
          end
        end
    end
  end
end
