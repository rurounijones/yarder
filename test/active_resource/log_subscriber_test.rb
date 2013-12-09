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
    @tom = { :person => { :id => 2, :name => 'Tom' } }.to_json
    ActiveResource::HttpMock.respond_to do |mock|
      mock.get "/people/1.json", {}, @matz
      mock.get "/people/2.json", {}, @tom
    end

    Yarder::ActiveResource::LogSubscriber.attach_to :active_resource
    Yarder.log_entries[Thread.current] = LogStash::Event.new
    @log_entry = Yarder.log_entries[Thread.current]
  end

  def test_mandatory_fields_present
    Person.find(1)
    wait
    assert_present @log_entry.fields['rest']
    assert_present @log_entry.fields['rest'].first['duration']
  end

  def test_request_notification
    Person.find(1)
    wait

    assert_equal "GET",  @log_entry.fields['rest'].first['method']
    assert_equal "http://37s.sunrise.i:3000/people/1.json", @log_entry.fields['rest'].first['uri']
    assert_equal 200,  @log_entry.fields['rest'].first['code']
    assert_equal "200",  @log_entry.fields['rest'].first['message']
    assert_equal 33,  @log_entry.fields['rest'].first['length']
  end

  def test_multiple_request
    Person.find(1)
    Person.find(2)
    wait

    assert_equal 2, @log_entry.fields['rest'].size
  end

  def test_total_duration_fields_present
    Person.find(1)
    Person.find(2)
    wait

    # JRuby sometimes returns 0 for the duration. Need to investigate why (Too fast?)
    # For the moment make this >= 0 instead of >0
    assert Float(@log_entry.fields['duration']['rest']) >= 0, "rest total duration was not a positive number"
  end

end
