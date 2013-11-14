require 'yarder/core_ext/object/blank'
require 'logger'
require 'yarder/logger'

module Yarder
  # Wraps any standard Logger object to provide tagging capabilities.
  #
  # logger = Yarder::TaggedLogging.new(Logger.new(STDOUT))
  # logger.tagged('BCX') { logger.info 'Stuff' } # Adds BCX to the @tags array and "Stuff" to the @message
  # logger.tagged('BCX', "Jason") { logger.info 'Stuff' } # Adds 'BCX' and 'Jason' to the @tags array and "Stuff"
  # to the @message
  # logger.tagged('BCX') { logger.tagged('Jason') { logger.info 'Stuff' } } # Adds 'BCX' and 'Jason' to the @tags
  # array and "Stuff" to the @message
  #
  # This is used by the default Rails.logger when the Yarder gem is added to a rails application
  # to make it easy to stamp JSON logs with subdomains, request ids, and anything else
  # to aid debugging of multi-user production applications.
  module TaggedLogging
    module Formatter # :nodoc:
      # This method is invoked when a log event occurs.
      def call(severity, timestamp, progname, msg)
        @entry = nil
        if msg.class == Yarder::Event
          @entry = msg
        else
          @entry = Yarder::Event.new(Rails.logger)
          @entry['message'] = msg
        end
        @entry['severity'] = severity
        @entry['tags'] ||= []

        process_tags(current_tags)
        process_tags(current_request_tags)
        #TODO Should we do anything with progname? What about source?
        super(severity, timestamp, progname, @entry.to_json)
      end

      def tagged(*tags)
        new_tags = push_tags(*tags)
        yield self
      ensure
        pop_tags(new_tags.size)
      end

      def push_tags(*tags)
        tags.flatten.reject(&:blank?).tap do |new_tags|
          current_tags.concat new_tags
        end
      end

      def push_request_tags(tags)
        Thread.current[:activesupport_tagged_logging_request_tags] = tags
      end

      def process_tags(tags)
        tags.each do |tag|
          if tag.class == Hash
            tag.each_pair do |k,v|
              @entry.fields[k] = v
            end
          else
            @entry['tags'] << tag
          end
        end
      end

      def pop_tags(size = 1)
        current_tags.pop size
      end

      def clear_tags!
        current_request_tags.clear
        current_tags.clear
      end

      def current_tags
        Thread.current[:activesupport_tagged_logging_tags] ||= []
      end

      def current_request_tags
        Thread.current[:activesupport_tagged_logging_request_tags] ||= []
      end

    end

    def self.new(logger)
      # Ensure we set a default formatter so we aren't extending nil!
      logger.formatter ||= ActiveSupport::Logger::SimpleFormatter.new
      logger.formatter.extend Formatter
      logger.extend(self)
    end

    delegate :push_tags, :push_request_tags, :pop_tags, :clear_tags!, to: :formatter

    def tagged(*tags)
      formatter.tagged(*tags) { yield self }
    end

    def flush
      clear_tags!
      super if defined?(super)
    end
  end
end
