module Configuration
  class DashboardAPI
    class << self
      def configured?
        !!AppSettings.dashboard_api_key
      end

      def key
        lambda do |env|
          AppSettings.dashboard_api_key
        end
      end
    end
  end
end