# yarder

JSON Based Replacement logging system for Ruby on Rails.

This is an experimental gem to see how easy / difficult it is to completely replace the default Ruby 
on Rails logging system with one based on outputting JSON messages.

This gem will create JSON based log entries designed for consumption by Logstash (although being 
JSON they can be read by other software). The JSON will contain the same information as can be found 
in the default rails logging output.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'yarder'
```

And then execute:

```
$ bundle
```

Or install it yourself as:

```
$ gem install yarder
```

This Gem currently requires the logstash-event gem to be installed on your system. This is currently 
not in rubygems so you will have to build it from source (See the Logstash repository)
