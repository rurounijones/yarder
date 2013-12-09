module Yarder
  module ActiveResource
    class LogSubscriber < ::ActiveSupport::LogSubscriber

      def request(event)
        request_entry = {}
        request_entry['method'] = event.payload[:method].to_s.upcase
        request_entry['uri'] = event.payload[:request_uri]

        result = event.payload[:result]

        request_entry['code'] = result.code
        request_entry['message'] = result.message
        request_entry['length'] = result.body.to_s.length
        request_entry['duration'] = event.duration

        entry.fields['rest'] ||= []
        entry.fields['rest'] << request_entry

        entry.fields['duration'] ||= {}
        entry.fields['duration']['rest'] ||= 0
        entry.fields['duration']['rest'] += event.duration.to_f
      end

    private

      def entry
        Yarder.log_entries[Thread.current]
      end

    end
  end
end
