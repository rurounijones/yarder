# yarder

JSON Based Replacement logging system for Ruby on Rails.

This is an experimental gem to see how easy / difficult it is to completely replace the default Ruby 
on Rails logging system with one based on outputting JSON messages.

This gem will create JSON based log entries designed for consumption by Logstash (although being 
JSON they can be read by other software). The JSON will contain the same information as can be found 
in the default rails logging output.

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
