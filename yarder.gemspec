$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "yarder/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "yarder"
  s.version     = Yarder::VERSION
  s.authors     = ["Jeffrey Jones"]
  s.email       = ["jjones@toppan-f.co.jp"]
  s.homepage    = "https://github.com/rurounijones/yarder"
  s.summary     = "JSON format based replacement for Ruby on Rails logging system"
  s.description = "Replaces the default string based Ruby on Rails logging system with a JSON based one"

  s.files = Dir["{app,config,db,lib}/**/*"] + ["MIT-LICENSE", "Rakefile", "README.md"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails", "~> 3.2.0"
  s.add_dependency "logstash-event", "~> 1.1.5"

  s.add_development_dependency(%q<capybara>, ['~> 1.1.2'])
end
