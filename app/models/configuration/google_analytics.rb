module Configuration
  class GoogleAnalytics
    class << self
      def configured?
        !!AppSettings.google_analytics_tracker
      end

      def tracker
        lambda do |env|
          AppSettings.google_analytics_tracker
        end
      end
    end
  end
end