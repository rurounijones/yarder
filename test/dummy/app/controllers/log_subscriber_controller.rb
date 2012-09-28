class LogSubscribersController < ActionController::Base
  wrap_parameters :person, :include => :name, :format => :json

  class SpecialException < Exception
  end

  rescue_from SpecialException do
    head :status => 406
  end

  before_filter :redirector, :only => :never_executed

  def never_executed
  end

  def show
    render :nothing => true
  end

  def redirector
    redirect_to "http://foo.bar/"
  end

  def data_sender
    send_data "cool data", :filename => "file.txt"
  end

  def file_sender
    send_file File.expand_path(File.join("test","dummy","public","favicon.ico"))
  end

  def with_fragment_cache
    render :inline => "<%= cache('foo'){ 'bar' } %>"
  end

  def with_fragment_cache_and_percent_in_key
    render :inline => "<%= cache('foo%bar'){ 'Contains % sign in key' } %>"
  end

  def with_page_cache
    cache_page("Super soaker", "/index.html")
    render :nothing => true
  end

  def with_exception
    raise Exception
  end

  def with_rescued_exception
    raise SpecialException
  end

  def with_action_not_found
    raise AbstractController::ActionNotFound
  end
end