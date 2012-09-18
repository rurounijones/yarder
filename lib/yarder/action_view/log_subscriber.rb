module Yarder
  module ActionView

    class LogSubscriber < ::ActiveSupport::LogSubscriber

      def render_template(event)
        entry.fields['rendering'] ||= []
        render_entry = {}
        render_entry['identifier'] = from_rails_root(event.payload[:identifier])
        render_entry['layout'] = from_rails_root(event.payload[:layout]) if event.payload[:layout]
        render_entry['duration'] = event.duration

        entry.fields['rendering'] << render_entry

      end
      alias :render_partial :render_template
      alias :render_collection :render_template

    private

      def from_rails_root(string)
        string.sub("#{Rails.root}/", "").sub(/^app\/views\//, "")
      end

      def entry
        @entry ||= Yarder.log_entries[Thread.current]
      end

    end
  end
end
