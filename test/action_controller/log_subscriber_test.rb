require "active_support/log_subscriber/test_helper"
require "test_helper"

class ACLogSubscriberTest < ActionController::TestCase
  tests LogSubscribersController
  include ActiveSupport::LogSubscriber::TestHelper

  def setup
    super

    @cache_path = File.expand_path('../temp/test_cache', File.dirname(__FILE__))
    ActionController::Base.page_cache_directory = @cache_path
    @controller.cache_store = :file_store, @cache_path

    Yarder::ActionController::LogSubscriber.attach_to :action_controller
    Yarder.log_entries[Thread.current] = LogStash::Event.new
    @log_entry = Yarder.log_entries[Thread.current]
  end

  def teardown
    super
    ActiveSupport::LogSubscriber.log_subscribers.clear
    FileUtils.rm_rf(@cache_path)
  end

  def set_logger(logger)
    ActionController::Base.logger = logger
  end

  def test_start_processing
    get :show, {:test => 'test'}
    wait

    assert_equal "LogSubscribersController", @log_entry.fields['controller']
    assert_equal "show", @log_entry.fields['action']
    assert_equal "html", @log_entry.fields['format']
  end


  def test_halted_callback
    get :never_executed
    wait

    assert_equal ":redirector" ,@log_entry.fields['halted_callback']
  end

  def test_process_action
    get :show
    wait

    assert_present @log_entry.fields['controller_duration']
  end

  def test_process_action_without_parameters
    get :show
    wait

    assert_blank @log_entry.fields['parameters']
  end

  def test_process_action_with_parameters
    get :show, :id => '10'
    wait

    assert_equal '10', @log_entry.fields['parameters']['id']
  end

  def test_process_action_with_wrapped_parameters
    @request.env['CONTENT_TYPE'] = 'application/json'
    post :show, :id => '10', :name => 'jose'
    wait

    assert_equal '10', @log_entry.fields['parameters']['id']
    assert_equal 'jose', @log_entry.fields['parameters']['name']
  end

  def test_process_action_with_filter_parameters
    @request.env["action_dispatch.parameter_filter"] = [:lifo, :amount]

    get :show, :lifo => 'Pratik', :amount => '420', :step => '1'
    wait

    params = @log_entry.fields['parameters']
    assert_equal '[FILTERED]', params['amount']
    assert_equal '[FILTERED]', params['lifo']
    assert_equal '1', params['step']
  end

  def test_redirect_to
    get :redirector
    wait

    assert_equal 'http://foo.bar/', @log_entry.fields['redirect_to']
  end


  def test_send_data
    get :data_sender
    wait

    assert_equal 'file.txt', @log_entry.fields['send_data']
    assert_present @log_entry.fields['send_data_duration']
  end


  def test_send_file
    get :file_sender
    wait

    assert_match 'test/dummy/public/favicon.ico', @log_entry.fields['send_file']
    assert_present @log_entry.fields['send_file_duration']
  end

  def test_with_fragment_cache
    @controller.config.perform_caching = true
    get :with_fragment_cache
    wait

    assert_present @log_entry.fields['cache']

    assert_match('Read fragment', @log_entry.fields['cache'].first['type'])
    assert_match('views/foo', @log_entry.fields['cache'].first['key_or_path'])

    assert_match('Write fragment', @log_entry.fields['cache'].last['type'])
    assert_match('views/foo', @log_entry.fields['cache'].last['key_or_path'])
  ensure
    LogSubscribersController.config.perform_caching = true
  end


  def test_with_fragment_cache_and_percent_in_key
    @controller.config.perform_caching = true
    get :with_fragment_cache_and_percent_in_key
    wait

    assert_present @log_entry.fields['cache']

    assert_match('Read fragment', @log_entry.fields['cache'].first['type'])
    assert_match('views/foo', @log_entry.fields['cache'].first['key_or_path'])

    assert_match('Write fragment', @log_entry.fields['cache'].last['type'])
    assert_match('views/foo', @log_entry.fields['cache'].last['key_or_path'])
  ensure
    LogSubscribersController.config.perform_caching = true
  end

=begin TODO Figure out why this last test fails.
  def test_with_page_cache
    @controller.config.perform_caching = true
    get :with_page_cache
    wait

   assert_present @log_entry.fields['cache']

    assert_match('Write page', @log_entry.fields['cache'][1]['type'])
    assert_match('index.html', @log_entry.fields['cache'][1]['key_or_path'])
  ensure
    @controller.config.perform_caching = true
  end
=end

  def logs
    @logs ||= @logger.logged(:info)
  end
end