# Yarder

[![Build Status](https://secure.travis-ci.org/rurounijones/yarder.png)](http://travis-ci.org/rurounijones/yarder)
[![Dependency Status](https://gemnasium.com/rurounijones/yarder.png)](https://gemnasium.com/rurounijones/yarder)
[![Code Climate](https://codeclimate.com/badge.png)](https://codeclimate.com/github/rurounijones/yarder)

JSON Based Replacement logging system for Ruby on Rails.

This is an experimental gem to see how easy / difficult it is to completely replace the default Ruby 
on Rails logging system with one based on outputting JSON messages.

This gem will create JSON based log entries designed for consumption by Logstash (although being 
JSON they can be read by other software). The JSON will contain the same information as can be found 
in the default rails logging output.

Yarder has only been tested against Rails 3.2.8 on Ruby 1.9.3 and JRuby running in 1.9 mode.

## Installation

Add this line to your Rails application's Gemfile:

```ruby
gem 'logstash-event', :path => 'vendor/logstash'
gem 'yarder'
```

And then execute the following within your Rails application:

```
git submodule add git://github.com/logstash/logstash.git vendor/logstash
bundle
bundle package --all
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

Yarder currently creates nested JSON. While this is supported in Logstash and Elastic Search the web 
interfaces do not as yet support it. Depending on whether support is possible or not Yarder may 
change to a non-nested format.

## Developers

For developers, after checking out this repository please run

```
git submodule update --init
bundle
rake
```
