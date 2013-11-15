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

      self['type'] = logger.log_type
      self['tags'] ||= []
      self.fields['duration'] = {}
      self.fields['env'] = logger.env
    end

    def write(rack = false)
      if @rack
        @logger.info self if rack
      else
        @logger.info self
      end
    end

    def self.create(logger, tags, rack = false)
      logger.push_request_tags(tags) if tags
      new(logger, rack)
    end

    def fields
      @fields ||= (@logstash_event[@logger.log_namespace.to_s] ||= {})
    end
  end

end
