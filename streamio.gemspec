# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "streamio/version"

Gem::Specification.new do |s|
  s.name        = "streamio"
  s.version     = Streamio::VERSION
  s.authors     = ["David Backeus"]
  s.email       = ["david@streamio.se"]
  s.homepage    = "http://github.com/streamio/streamio-rb"
  s.summary     = %q{Ruby wrapper for the Streamio API.}
  s.description = %q{Ruby wrapper for Streamios API.}

  s.files       = Dir.glob("lib/**/*") + %w(Gemfile streamio.gemspec HISTORY README.rdoc)
  
  s.add_dependency("rest-client", "~> 1.6.1")
  s.add_dependency("multi_json", "~> 1.0.4")
  
  s.add_development_dependency("rspec", "~> 2.7")
  s.add_development_dependency("webmock", "~> 1.7.8")
  s.add_development_dependency("rake", "~> 0.9.2")
end
