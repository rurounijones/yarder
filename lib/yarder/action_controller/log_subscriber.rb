require 'yarder/core_ext/object/blank'

module Yarder
  module ActionController
    class LogSubscriber < ::ActiveSupport::LogSubscriber
      INTERNAL_PARAMS = %w(controller action format _method only_path)

      def start_processing(event)
        payload = event.payload

        entry['controller'] = payload[:controller]
        entry['action'] = payload[:action]

        format  = payload[:format]
        entry['format']  = format.to_s.downcase if format.is_a?(Symbol)

      end

      def process_action(event)

        payload   = event.payload
        #TODO Think about additions. Comment out for the moment to shut up warnings
        #additions = ::ActionController::Base.log_process_action(payload)

        params = payload[:params].except(*INTERNAL_PARAMS)
        entry['parameters'] = params unless params.empty?

        entry['controller_duration'] = event.duration

        #TODO  What on earth are additions and how should we handle them?
        # message << " (#{additions.join(" | ")})" unless additions.blank?

      end

      def halted_callback(event)
        entry['halted_callback'] = event.payload[:filter]
      end

      def send_file(event)
        entry['send_file'] = event.payload[:path]
        entry['send_file_duration'] = event.duration
      end

      def redirect_to(event)
        entry['redirect_to'] = event.payload[:location]
      end

      def send_data(event)
        entry['send_data'] = event.payload[:filename]
        entry['send_data_duration'] = event.duration
      end

      %w(write_fragment read_fragment exist_fragment?
         expire_fragment expire_page write_page).each do |method|
        class_eval <<-METHOD, __FILE__, __LINE__ + 1
          def #{method}(event)
            entry['cache'] ||= []
            cache_event = {}
            cache_event['key_or_path'] = event.payload[:key] || event.payload[:path]
            cache_event['type'] = #{method.to_s.humanize.inspect}
            cache_event['duration'] = event.duration
            entry['cache'] << cache_event
          end
        METHOD
      end

    private

      def entry
        Yarder.log_entries[Thread.current]
      end

    end
  end
end
