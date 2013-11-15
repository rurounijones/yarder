require 'test_helper'

# TODO These tests are fragile because they rely on the output being added
# to the last line of the log file. See if there is a better way to do this
class LoggerTest < ActiveSupport::IntegrationCase
  class MyLogger < Yarder::Logger
    def flush(*)
    end

  end

  setup do
    @output = StringIO.new
    Rails.logger = Yarder::TaggedLogging.new(MyLogger.new(@output))
    Rails.logger.log_namespace = :rack
    visit('/widgets')
  end

  test 'writes a hash to the log file when a request is received' do
    assert_equal Hash, entry.class
  end

  test 'fills in the client_ip' do
    assert_equal "127.0.0.1", entry['rack']['client_ip']
  end

  test 'fills in the method' do
    assert_equal "GET", entry['rack']['method']
  end

  test 'fills in the path' do
    assert_equal "/widgets", entry['rack']['path']
  end

  test 'fills in the status' do
    assert_equal "/widgets", entry['rack']['path']
  end

  test 'fills in the total_duration' do
    assert entry['rack']['duration']['total'].to_f > 0, "total duration was not a positive number"
  end

  test 'total_duration is greater than sql_duration' do
    duration = entry['rack']['duration']
    assert duration['total'].to_f >= duration['sql'].to_f, "total duration is less than sql duration"
  end

  test 'total_duration is greater than controller_duration' do
    duration = entry['rack']['duration']
    assert entry['rack']['duration']['total'].to_f >= duration['controller'].to_f, "total_duration is less than controller_duration"
  end

  test 'fills in the sql_duration' do
    duration = entry['rack']['duration']
    assert duration['sql'].to_f >= 0, "sql_duration was not a positive number"
  end

  test 'fills in the method name tag' do
    assert_equal 32, entry['rack']['uuid'].size
  end

  test 'fills in the string tag' do
    assert_match "Hello", entry['tags'].first
  end

  test 'fills in the proc tag' do
    assert_match "Proc", entry['tags'].last
  end

  test 'fills in the sql quer' do
    assert entry['rack']['sql'].last['sql'], '"SELECT "widgets".* FROM "widgets"'
  end

=begin TODO Add tests for view rendering
  test 'fills in the rendering' do
    assert_present entry['rack']['rendering'] , "rendering is blank"
  end

  test 'fills in the rendering_duration' do
    assert_present entry['rack']['rendering_duration'] , "rendering_duration is blank"
    assert Float(entry['rack']['rendering_duration']) >= 0, "rendering_duration was not a positive number"
  end
=end

  def entry
    JSON.parse(@output.string)
  end

end
