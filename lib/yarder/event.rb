module Yarder

  # Basically a wrapper for a LogStash event that keeps track of if it was created from a rack
  # middle-ware or not. This is important when it comes to deciding when to write the log
  class Event
    extend Forwardable
    def_delegators :@logstash_event, :[]=, :[], :to_json

    def initialize(logger, rack = false)
      @logger = logger
      @rack = rack
      @logstash_event = LogStash::Event.new
    end

    def write(rack = false)
      if @rack
        @logger.info self if rack
      else
        @logger.info self
      end
    end

    def add_tags_to_logger(request, tags)
      tag_hash = []
      if tags
        tags.each do |tag|
          case tag
          when Symbol
            tag_hash << {tag.to_s => request.send(tag) }
          when Proc
            tag_hash << tag.call(request)
          else
            tag_hash << tag
          end
        end
      end

      @logger.push_request_tags(tag_hash)
    end

    def fields
      @fields ||= (@logstash_event[@logger.log_namespace.to_s] ||= {})
    end
  end

end
