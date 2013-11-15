require 'yarder/core_ext/object/blank'

module Yarder
  module ActionController
    class LogSubscriber < ::ActiveSupport::LogSubscriber
      INTERNAL_PARAMS = %w(controller action format _method only_path)

      def start_processing(event)
        payload = event.payload

        entry['name'] = payload[:controller]
        entry['action'] = payload[:action]

        format  = payload[:format]
        entry['format']  = format.to_s.downcase if format.is_a?(Symbol)

      end

      def process_action(event)
        payload   = event.payload

        params = payload[:params].except(*INTERNAL_PARAMS)
        entry['parameters'] = params unless params.empty?

        root['duration']['controller'] = event.duration
      end

      def halted_callback(event)
        entry['halted_callback'] = event.payload[:filter]
      end

      def send_file(event)
        entry['send_file'] = event.payload[:path]
        root['duration']['send_file'] = event.duration
      end

      def redirect_to(event)
        entry['redirect_to'] = event.payload[:location]
      end

      def send_data(event)
        entry['send_data'] = event.payload[:filename]
        root['duration']['send_data'] = event.duration
      end

      %w(write_fragment read_fragment exist_fragment?
         expire_fragment expire_page write_page).each do |method|
        class_eval <<-METHOD, __FILE__, __LINE__ + 1
          def #{method}(event)
            cache_event = {}
            cache_event['key_or_path'] = event.payload[:key] || event.payload[:path]
            cache_event['type'] = #{method.to_s.humanize.inspect}
            cache_event['duration'] = event.duration
            cache << cache_event
            root['duration']['cache'] ||= 0
            root['duration']['cache'] += event.duration.to_f
          end
        METHOD
      end

    private

      def entry
        @entry ||= (root['controller'] ||= {})
      end

      def cache
        @cache ||= (root['cache'] ||= [])
      end

      def root
        @root ||= Yarder.log_entries[Thread.current].fields.tap { |o| o['duration'] ||= {} }
      end

    end
  end
end
