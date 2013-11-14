module Yarder

  module Rack

    class Logger

      def initialize(app, tags = nil)
        @app, @tags = app, tags.presence
      end

      def call(env)

        t1 = Time.now
        request = ActionDispatch::Request.new(env)

        event = Yarder::Event.new(Rails.logger, true)
        event['message'] = "#{request.request_method} #{request.filtered_path} for #{request.ip}"
        event['client_ip'] = request.ip
        event['method'] = request.request_method
        event['path'] = request.filtered_path
        #TODO Should really move this into the base logger
        event['source'] = "http://#{Socket.gethostname}#{request.filtered_path}"
        event['type'] = "rails_json_log"

        event.add_tags_to_logger(request, @tags) if @tags

        Yarder.log_entries[Thread.current] = event

        status, headers, response = @app.call(env)
        [status, headers, response]

      ensure
        if event
          event['total_duration'] = Time.now - t1
          event['status'] = status

          ['rendering','sql'].each do |type|
            if event[type] && !event[type].empty?
              duration = event[type].inject(0) {|result, local_event| result += local_event['duration'].to_f }
              event["#{type}_duration"] = duration
            end
          end

          event.write(true)
        end

        Yarder.log_entries[Thread.current] = nil
      end

    end

  end

end
