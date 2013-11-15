require "securerandom"

module Yarder
  module ActiveRecord
    class LogSubscriber < ::ActiveSupport::LogSubscriber

      def self.runtime=(value)
        Thread.current["active_record_sql_runtime"] = value
      end

      def self.runtime
        Thread.current["active_record_sql_runtime"] ||= 0
      end

      def self.reset_runtime
        rt, self.runtime = runtime, 0
        rt
      end

      def initialize
        super
      end

      def sql(event)
        self.class.runtime += event.duration
        return unless logger.debug?

        payload = event.payload

        return if 'SCHEMA' == payload[:name]

        sql_entry = {}
        sql_entry['name'] = payload[:name]
        sql_entry['duration'] = event.duration
        sql_entry['sql']= payload[:sql].squeeze(' ')

        binds = nil

        unless (payload[:binds] || []).empty?
          binds = "  " + payload[:binds].map { |col,v|
            [col.name, v]
          }.inspect
        end

        sql_entry['binds'] = binds unless binds.nil?

        write_entry sql_entry
      end

      def identity(event)
        return unless logger.debug?

        payload = event.payload

        sql_entry = {}
        sql_entry['name'] = payload[:name]
        sql_entry['line'] = payload[:line]
        sql_entry['duration'] = payload[:duration]

        write_entry sql_entry
      end

    private

      def write_entry(sql_entry)
        entry = log_entry
        entry.fields['sql'] ||= []
        entry.fields['sql'] << sql_entry
        entry.write(false)
      end

      def logger
        ::ActiveRecord::Base.logger
      end

      def log_entry
        Yarder.log_entries[Thread.current] ||
          Yarder::Event.new(Rails.logger, false).tap do |entry|
          entry.fields['uuid'] = SecureRandom.uuid
        end
      end

    end
  end
end
