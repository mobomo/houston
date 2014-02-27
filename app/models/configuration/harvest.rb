module Configuration
  module Harvest
    extend self

    # @return [true|false]
    def configured?
      !!(identifier && secret)
    end

    # @return [String]
    def identifier
      AppSettings.harvest_identifier
    end

    # @return [String]
    def secret
      AppSettings.harvest_secret
    end
  end
end
