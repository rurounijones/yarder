module Yarder

  module Rack

    class Logger

      def initialize(app, tags = nil)
        @app, @tags = app, tags.presence
      end

      def call(env)

        t1 = Time.now
        request = ActionDispatch::Request.new(env)

        event = Yarder::Event.create Rails.logger, tags(request), true
        event['message'] = "#{request.request_method} #{request.filtered_path} for #{request.ip}"

        entry = (event.fields['rack'] ||= {})
        entry['client_ip'] = request.ip
        entry['method'] = request.request_method
        entry['path'] = request.filtered_path
        entry['url'] = request.url

        Yarder.log_entries[Thread.current] = event

        status, headers, response = @app.call(env)
        [status, headers, response]
      ensure
        if event
          entry['status'] = status
          event.fields['duration']['total'] = (Time.now - t1)*1000
          event.write(true)
        end

        Yarder.log_entries[Thread.current] = nil
      end

      def tags(request)
        return unless @tags
        @tags.reduce([]) do |arr, tag|
          case tag
          when Symbol
            arr << {tag.to_s => request.send(tag) }
          when Proc
            arr << tag.call(request)
          else
            arr << tag
          end
        end
      end

    end

  end

end
