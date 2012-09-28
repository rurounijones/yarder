require "active_support/log_subscriber/test_helper"
require "lib/controller/fake_models"

class AVLogSubscriberTest < ActiveSupport::TestCase
  include ActiveSupport::LogSubscriber::TestHelper

  def setup
    super
    view_paths = ActionController::Base.view_paths
    lookup_context = ActionView::LookupContext.new(view_paths, {}, ["test"])
    renderer = ActionView::Renderer.new(lookup_context)
    @view = ActionView::Base.new(renderer, {})
    Yarder::ActionView::LogSubscriber.attach_to :action_view
    Yarder.log_entries[Thread.current] = LogStash::Event.new
    @log_entry = Yarder.log_entries[Thread.current]
  end

  def teardown
    super
    ActiveSupport::LogSubscriber.log_subscribers.clear
  end

  def test_mandatory_fields_present
    @view.render(:file => "test/hello_world")
    wait

    assert_present @log_entry.fields['rendering']
    assert_present @log_entry.fields['rendering'].first['duration']
  end

  def test_render_file_template
    @view.render(:file => "test/hello_world")
    wait

    assert_equal("test/hello_world.erb", @log_entry.fields['rendering'].first['identifier'])
  end

  def test_render_text_template
    @view.render(:text => "TEXT")
    wait

    assert_equal("text template", @log_entry.fields['rendering'].first['identifier'])
  end

  def test_render_inline_template
    @view.render(:inline => "<%= 'TEXT' %>")
    wait

    assert_equal("inline template", @log_entry.fields['rendering'].first['identifier'])
  end

  def test_render_partial_template
    @view.render(:partial => "test/customer")
    wait

    assert_equal("test/_customer.erb", @log_entry.fields['rendering'].first['identifier'])
  end

  def test_render_partial_with_implicit_path
    @view.render(Customer.new("david"), :greeting => "hi")
    wait

    assert_equal("customers/_customer.html.erb", @log_entry.fields['rendering'].first['identifier'])
  end

  def test_render_collection_template
    @view.render(:partial => "test/customer", :collection => [ Customer.new("david"), Customer.new("mary") ])
    wait

    assert_equal("test/_customer.erb", @log_entry.fields['rendering'].first['identifier'])
  end

  def test_render_collection_with_implicit_path
    @view.render([ Customer.new("david"), Customer.new("mary") ], :greeting => "hi")
    wait

    assert_equal("customers/_customer.html.erb", @log_entry.fields['rendering'].first['identifier'])
  end

  def test_render_collection_template_without_path
    @view.render([ GoodCustomer.new("david"), Customer.new("mary") ], :greeting => "hi")
    wait

    assert_equal("collection", @log_entry.fields['rendering'].first['identifier'])
  end

  #TODO Add tests regarding layout

end