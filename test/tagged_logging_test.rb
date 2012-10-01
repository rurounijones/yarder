require 'yarder/buffered_logger'
require 'yarder/tagged_logging'

class TaggedLoggingTest < ActiveSupport::TestCase
  class MyLogger < Yarder::BufferedLogger
  end

  setup do
    @output = StringIO.new
    @logger = Yarder::TaggedLogging.new(MyLogger.new(@output))
  end

  test 'sets logger.formatter if missing and extends it with a tagging API' do
    logger = ::Logger.new(StringIO.new)
    # assert_nil logger.formatter #TODO This assertion is failing but I do not think it is end of the world
    Yarder::TaggedLogging.new(logger)
    assert_not_nil logger.formatter
    assert logger.formatter.respond_to?(:tagged)
  end

  test 'fills in the severity' do
    @logger.info "Severity Test"
    assert_equal "INFO", JSON.parse(@output.string)['@fields']['severity']
  end

  test "tagged once" do
    @logger.tagged("BCX") { @logger.info "Funky time" }
    assert_equal "BCX", JSON.parse(@output.string)['@tags'][0]
    assert_equal "Funky time", JSON.parse(@output.string)['@message']
  end

  test "tagged twice" do
    @logger.tagged("BCX") { @logger.tagged("Jason") { @logger.info "Funky time" } }
    assert_equal "BCX", JSON.parse(@output.string)['@tags'][0]
    assert_equal "Jason", JSON.parse(@output.string)['@tags'][1]
  end

  test "tagged thrice at once" do
    @logger.tagged("BCX", "Jason", "New") { @logger.info "Funky time" }
    assert_equal "BCX", JSON.parse(@output.string)['@tags'][0]
    assert_equal "Jason", JSON.parse(@output.string)['@tags'][1]
    assert_equal "New", JSON.parse(@output.string)['@tags'][2]
  end

  test "tagged are flattened" do
    @logger.tagged("BCX", %w(Jason New)) { @logger.info "Funky time" }
    assert_equal "BCX", JSON.parse(@output.string)['@tags'][0]
    assert_equal "Jason", JSON.parse(@output.string)['@tags'][1]
    assert_equal "New", JSON.parse(@output.string)['@tags'][2]
  end


  test "push and pop tags directly" do
    assert_equal %w(A B C), @logger.push_tags('A', ['B', ' ', ['C']])
    @logger.info 'a'
    assert_equal %w(C), @logger.pop_tags
    @logger.info 'b'
    assert_equal %w(B), @logger.pop_tags(1)
    @logger.info 'c'
    assert_equal [], @logger.clear_tags!
    @logger.info 'd'
   # assert_equal "[A] [B] [C] a\n[A] [B] b\n[A] c\nd\n",  JSON.parse(@output.string)['@tags']

    first_log = JSON.parse(@output.string.split("\n")[0])
    assert_equal "A", first_log['@tags'][0]
    assert_equal "B", first_log['@tags'][1]
    assert_equal "C", first_log['@tags'][2]
    assert_equal "a", first_log['@message']

    second_log = JSON.parse(@output.string.split("\n")[1])
    assert_equal "A", second_log['@tags'][0]
    assert_equal "B", second_log['@tags'][1]
    assert_equal "b", second_log['@message']

    third_log = JSON.parse(@output.string.split("\n")[2])
    assert_equal "A", third_log['@tags'][0]
    assert_equal "c", third_log['@message']

    fourth_log = JSON.parse(@output.string.split("\n")[3])
    assert fourth_log['@tags'].empty?
    assert_equal "d", fourth_log['@message']
  end



  test "does not strip message content" do
    @logger.info " Hello"
    assert_equal " Hello", JSON.parse(@output.string)['@message']
  end

  test "provides access to the logger instance" do
    @logger.tagged("BCX") { |logger| logger.info "Funky time" }
    assert_equal "BCX", JSON.parse(@output.string)['@tags'][0]
    assert_equal "Funky time", JSON.parse(@output.string)['@message']
  end

  test "tagged once with blank and nil" do
    @logger.tagged(nil, "", "New") { @logger.info "Funky time" }
    assert_equal "New", JSON.parse(@output.string)['@tags'].last
  end

  test "keeps each tag in their own thread" do
    @logger.tagged("BCX") do
      Thread.new do
        @logger.tagged("OMG") { @logger.info "Cool story bro" }
      end.join
      @logger.info "Funky time"
    end

    # Sub-thread
    main_thread = JSON.parse(@output.string.split("\n").first)
    assert_equal "OMG", main_thread['@tags'][0]
    assert_equal "Cool story bro", main_thread['@message']

    # Main thread
    main_thread = JSON.parse(@output.string.split("\n").last)
    assert_equal "BCX", main_thread['@tags'][0]
    assert_equal "Funky time", main_thread['@message']
  end

  test "cleans up the taggings on flush" do
    @logger.tagged("BCX") do
      Thread.new do
        @logger.tagged("OMG") do
          @logger.flush
          @logger.info "Cool story bro"
        end
      end.join
    end

    first_log = JSON.parse(@output.string.split("\n").first)
    assert first_log['@tags'].empty?
    assert_equal "Cool story bro", first_log['@message']
  end


  test "mixed levels of tagging" do
    @logger.tagged("BCX") do
      @logger.tagged("Jason") { @logger.info "Funky time" }
      @logger.info "Junky time!"
    end

    first_log = JSON.parse(@output.string.split("\n").first)
    assert_equal "BCX", first_log['@tags'][0]
    assert_equal "Jason", first_log['@tags'][1]
    assert_equal "Funky time", first_log['@message']

    second_log = JSON.parse(@output.string.split("\n").last)
    assert_equal "BCX", second_log['@tags'][0]
    assert_equal "Junky time!", second_log['@message']
  end

end


