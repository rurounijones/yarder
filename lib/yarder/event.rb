module Yarder

  # Basically a wrapper for a LogStash event that keeps track of if it was created from a rack
  # middle-ware or not. This is important when it comes to deciding when to write the log
  class Event

    extend Forwardable
    def_delegators :@logstash_event, :fields, :message=, :source=, :type=, :tags, :to_json

    def initialize(rack = false)
      @rack = rack
      @logstash_event = LogStash::Event.new
    end

    def rack?
      @rack
    end

  end

end