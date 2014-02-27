module Configuration
  class Feedback
    class << self
      def configured?
        !!AppSettings.feedback_url
      end

      def url
        AppSettings.feedback_url
      end
    end
  end
end