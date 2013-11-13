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
    visit('/widgets')
  end

  test 'writes a hash to the log file when a request is received' do
    assert_equal Hash, entry.class
  end

  test 'fills in the client_ip' do
    assert_equal "127.0.0.1", entry['client_ip']
  end

  test 'fills in the method' do
    assert_equal "GET", entry['method']
  end

  test 'fills in the path' do
    assert_equal "/widgets", entry['path']
  end

  test 'fills in the status' do
    assert_equal "/widgets", entry['path']
  end

  test 'fills in the total_duration' do
    assert entry['total_duration'].to_f >= 0, "total_duration was not a positive number"
  end

  test 'fills in the rendering_duration' do
    assert entry['rendering_duration'].to_f >= 0, "rendering_duration was not a positive number"
  end

  test 'fills in the sql_duration' do
    assert entry['rendering_duration'].to_f >= 0, "sql_duration was not a positive number"
  end

  test 'fills in the method name tag' do
    assert_equal 32, entry['uuid'].size
  end

  test 'fills in the string tag' do
    assert_match "Hello", entry['tags'].first
  end

  test 'fills in the proc tag' do
    assert_match "Proc", entry['tags'].last
  end

  #TODO Add tests for view and SQL rendering summaries

  def entry
    JSON.parse(@output.string)
  end

end
