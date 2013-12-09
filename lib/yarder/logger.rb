require 'logger'
require 'socket'

module Yarder

  # Based on the ActiveSupport::Logger (Formerly known as BufferedLogger)
  class Logger < ::Logger
    # Broadcasts logs to multiple loggers.
    def self.broadcast(logger) # :nodoc:
      Module.new do
        define_method(:add) do |*args, &block|
          logger.add(*args, &block)
          super(*args, &block)
        end

        define_method(:<<) do |x|
          logger << x
          super(x)
        end

        define_method(:close) do
          logger.close
          super()
        end

        define_method(:progname=) do |name|
          logger.progname = name
          super(name)
        end

        define_method(:formatter=) do |formatter|
          logger.formatter = formatter
          super(formatter)
        end

        define_method(:level=) do |level|
          logger.level = level
          super(level)
        end
      end
    end

    attr_accessor :log_type, :log_namespace

    def initialize(*args)
      super
      self.log_type = :rails_json_log
      self.log_namespace = :rails
      @formatter = SimpleFormatter.new
    end

    def env
      @env ||= {
        :ruby => "#{RUBY_VERSION}-p#{RUBY_PATCHLEVEL}",
        :env => Rails.env,
        :pwd => Dir.pwd,
        :program => $0,
        :user => ENV['USER'],
        :host => ::Socket.gethostname
      }
    end

    # Simple formatter which only displays the message.
    class SimpleFormatter < ::Logger::Formatter
      # This method is invoked when a log event occurs
      def call(severity, timestamp, progname, msg)
        "#{String === msg ? msg : msg.inspect}\n"
      end
    end
  end
end
