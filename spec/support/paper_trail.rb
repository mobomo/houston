module PaperTrail
  module RSpec
    module Extensions

      def with_versioning
        was_enabled = ::PaperTrail.enabled?
        was_enabled_for_controller = ::PaperTrail.enabled_for_controller?
        ::PaperTrail.enabled = true
        ::PaperTrail.enabled_for_controller = true
        begin
          yield
        ensure
          ::PaperTrail.enabled = was_enabled
          ::PaperTrail.enabled_for_controller = was_enabled_for_controller
        end
      end

    end
  end
end
