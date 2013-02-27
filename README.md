# Yarder

[![Build Status](https://secure.travis-ci.org/rurounijones/yarder.png)](http://travis-ci.org/rurounijones/yarder)
[![Coverage Status](https://coveralls.io/repos/rurounijones/yarder/badge.png?branch=master)](https://coveralls.io/r/rurounijones/yarder)
[![Code Climate](https://codeclimate.com/github/rurounijones/yarder.png)](https://codeclimate.com/github/rurounijones/yarder)
[![Dependency Status](https://gemnasium.com/rurounijones/yarder.png)](https://gemnasium.com/rurounijones/yarder)

JSON Based Replacement logging system for Ruby on Rails.

This is an experimental gem to see how easy / difficult it is to completely replace the default Ruby 
on Rails logging system with one based on outputting JSON messages.

This gem will create JSON based log entries designed for consumption by Logstash (although being 
JSON they can be read by other software). The JSON will contain the same information as can be found 
in the default rails logging output.

## Current Status

This gem is not production ready however it is probably ready for people interested in seeing the 
results. All logging in a Rails3 app should be JSON formatted, including ad-hoc logging.

Yarder has only been tested against Rails 3.2.8 on Ruby 1.9.3 and JRuby running in 1.9 mode. Test
coverage is reasonable and most of the original Rails3 logging tests are passing. Additional tests
unique to this gem still need to be created.

There may be issues regarding outputting UTF-8 characters in logs on JRuby 1.6 in --1.9 mode. JRuby
1.7 is recommended (These same issues exist in the man ruby loggers so use that as a guide).

Any help, feedback or pull-requests would be much appreciated, especially related to refactoring and 
test improvement

## Installation

Add this line to your Rails application's Gemfile:

```ruby
gem 'yarder'
```

## Configuration

Yarder uses the Rails logger (set using config.logger in application.rb)to log output.

By default Rails uses the TaggedLogging class to provide this however because Yarder
replaces it you will need to change the default to something else.

You will need to specify a Ruby Logger compatible logger. Yarder provides its own
logger which is a copy of the ActiveSupport::Logger (Formerly known as
ActiveSupport::BufferedLogger)

If you are not sure what you want yet then set the Yarder::Logger as in the example
below in your application.rb file.

```ruby
module MyApp
  class Application < Rails::Application

    # Set a logger compatible with the standard ruby logger to be used by Yarder
    config.logger = Yarder::Logger.new(Rails.root.join('log',"#{Rails.env}.log").to_s)

  end
end
```

## Logstash Configuration

Yarder currently creates log entries with a hard-coded logtype of "rails_json_log" (This may change 
in future and may become configurable) therefore your Logstash configuration file should be as 
follows:

```
input {
  file {
    type => "rails_json_log"
    path => "/var/www/rails/application-1/log/production.log" # Path to your log file
    format => "json_event"
  }
}
```

You will need to edit the path to point to your application's log file. Because Yarder creates json 
serialized Logstash::Event entries there is no need to setup any filters

### Known issues

Yarder currently creates nested JSON. Kibana has pretty good (With a few small UI problems) support
for nested JSON but logstash web does not.

## Developers

Thoughts, suggestions, opinions and contributions are welcome. 

When contributing please make sure to run your tests with warnings enabled and make sure that
yarder creates no warnings. (Warnings from other libraries like capybara etc. are ok)

```
RUBYOPT=-w rake
```


