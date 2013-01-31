require 'yarder/railtie' if defined?(Rails)
require 'yarder/rack/logger'
require 'yarder/event'
require 'logstash-event'
require 'yarder/logger'
require 'yarder/tagged_logging'

module Yarder

  class IncompatibleLogger < StandardError; end

  def self.log_entries
    @@events ||= {}
  end

end
