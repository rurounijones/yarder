require 'yarder/railtie' if defined?(Rails)
require 'yarder/rack/logger'
require 'logstash-event'
require 'yarder/logger'
require 'yarder/tagged_logging'

module Yarder

  def self.log_entries
    @@events ||= {}
  end

end
