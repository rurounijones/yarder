module Yarder

  module Rack

    class Logger

      def initialize(app, tags = nil)
        @app, @tags = app, tags.presence
      end

      def call(env)

        t1 = Time.now
        request = ActionDispatch::Request.new(env)

        event = LogStash::Event.new
        event.message = "#{request.request_method} #{request.filtered_path} for #{request.ip}"
        event.fields['client_ip'] = request.ip
        event.fields['method'] = request.request_method
        event.fields['path'] = request.filtered_path
        #TODO Should really move this into the base logger
        event.source = "http://#{Socket.gethostname}#{request.filtered_path}"
        event.type = "rails_json_log"

        add_tags_to_logger(request) if @tags

        Yarder.log_entries[Thread.current] = event

        status, headers, response = @app.call(env)
        [status, headers, response]

      ensure
        if event
          event.fields['total_duration'] = Time.now - t1
          event.fields['status'] = status

          ['rendering','sql'].each do |type|
            if event.fields[type] && !event.fields[type].empty?
              duration = event.fields[type].inject(0) {|result, event| result += event[:duration].to_f }
              event.fields["#{type}_duration"] = duration
            end
          end

          Rails.logger.info event
        end

        Yarder.log_entries[Thread.current] = nil
      end

      def add_tags_to_logger(request)
        tags = []
        if @tags
          @tags.each do |tag|
            case tag
            when Symbol
              tags << {tag.to_s => request.send(tag) }
            when Proc
              tags << tag.call(request)
            else
              tags << tag
            end
          end
        end

        Rails.logger.push_request_tags(tags)
      end

    end

  end

end
