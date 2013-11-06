source "http://rubygems.org"

# Declare your gem's dependencies in yarder.gemspec.
# Bundler will treat runtime dependencies like base dependencies, and
# development dependencies will be added by default to the :development group.
gemspec

# jquery-rails is used by the dummy application
gem 'jquery-rails'

# Declare any dependencies that are still in development here instead of in
# your gemspec. These might include edge Rails or gems from your path or
# Git. Remember to move these dependencies to your gemspec before releasing
# your gem to rubygems.org.

# To use debugger
#gem 'debugger'

gem 'logstash-event', '~>1.1.5'

group :development, :test do
  gem 'simplecov', :require => false, :platform => :ruby
  gem 'capybara', '~>1.1.2'
  gem 'sqlite3', :platform => :ruby

  gem 'jdbc-sqlite3', :platform => :jruby
  gem 'activerecord-jdbcsqlite3-adapter', :platform => :jruby
  gem 'coveralls', require: false

end

