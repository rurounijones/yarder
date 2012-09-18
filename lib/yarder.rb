require 'yarder/railtie' if defined?(Rails)
require 'yarder/rack/logger'
require 'logstash-event'

module Yarder

  def self.log_entries
    @@events ||= {}
  end

end
