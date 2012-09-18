module Yarder
  module ActiveResource
    class LogSubscriber < ::ActiveSupport::LogSubscriber

      def request(event)

        #TODO Think of a better name for this!
        entry.fields['active_resource'] ||= []

        request_entry = {}
        request_entry['method'] = event.payload[:method].to_s.upcase
        request_entry['uri'] = event.payload[:request_uri]

        result = event.payload[:result]

        request_entry['code'] = result.code
        request_entry['message'] = result.message
        request_entry['length'] = result.length
        request_entry['duration'] = event_duration

        entry.fields['active_resource'] << request_entry
      end

    private

      def entry
        @entry ||= Yarder.log_entries[Thread.current]
      end

    end
  end
end

