module Yarder

  module Rack

    class Logger

      def initialize(app, tags = nil)
        @app, @tags = app, tags.presence
      end

      def call(env)
        request = ActionDispatch::Request.new(env)

        event = LogStash::Event.new
        event.message = "#{request.request_method} #{request.filtered_path} for #{request.ip}"
        event.fields['client_ip'] = request.ip
        event.fields['method'] = request.request_method
        event.fields['path'] = request.filtered_path
        event.source = "http://#{Socket.gethostname}#{request.filtered_path}"
        event.type = "rails_json_log"

        if @tags
          @tags.each do |tag|
            case tag
            when Symbol
              event.fields[tag.to_s] = request.send(tag)
            when Proc
              event.tags << tag.call(request)
            else
              event.tags << tag
            end
          end
        end


        Yarder.log_entries[Thread.current] = event

        status, headers, response = @app.call(env)

        Yarder.log_entries[Thread.current].fields['status'] = status

        [status, headers, response]

      ensure

        event = Yarder.log_entries[Thread.current]

        if event

          if event.fields['rendering'] && !event.fields['rendering'].empty?
            rendering_duration = event.fields['rendering'].inject(0) {|result, event| result += event[:duration].to_f }
            event.fields['rendering_duration'] = rendering_duration
          end

          if event.fields['sql'] && !event.fields['sql'].empty?
            sql_duration = event.fields['sql'].inject(0) {|result, event| result += event[:duration].to_f }
            event.fields['sql_duration'] = sql_duration
          end

          Rails.logger.info event.to_json

        end

        Yarder.log_entries[Thread.current] = nil
      end




    end

  end

end