require "active_support/log_subscriber/test_helper"
require "active_support/core_ext/hash/conversions"

class Person < ActiveResource::Base
  self.site = "http://37s.sunrise.i:3000"
end

class AResourceLogSubscriberTest < ActiveSupport::TestCase
  include ActiveSupport::LogSubscriber::TestHelper

  def setup
    super

    @matz = { :person => { :id => 1, :name => 'Matz' } }.to_json
    ActiveResource::HttpMock.respond_to do |mock|
      mock.get "/people/1.json", {}, @matz
    end

    Yarder::ActiveResource::LogSubscriber.attach_to :active_resource
    Yarder.log_entries[Thread.current] = LogStash::Event.new
    @log_entry = Yarder.log_entries[Thread.current]
  end

  def test_mandatory_fields_present
    Person.find(1)
    wait
    assert_present @log_entry.fields['active_resource']
    assert_present @log_entry.fields['active_resource'].first['duration']
  end

  def test_request_notification
    Person.find(1)
    wait

    assert_equal "GET",  @log_entry.fields['active_resource'].first['method']
    assert_equal "http://37s.sunrise.i:3000/people/1.json", @log_entry.fields['active_resource'].first['uri']
    assert_equal 200,  @log_entry.fields['active_resource'].first['code']
    assert_equal "200",  @log_entry.fields['active_resource'].first['message']
    assert_equal 33,  @log_entry.fields['active_resource'].first['length']
  end

end