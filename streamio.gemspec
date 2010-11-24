# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "streamio/version"

Gem::Specification.new do |s|
  s.name        = "streamio"
  s.version     = Streamio::VERSION
  s.authors     = ["David Backeus"]
  s.email       = ["david@streamio.se"]
  s.homepage    = "http://github.com/streamio/streamio-rb"
  s.summary     = %q{Ruby wrapper for the Streamio api.}
  s.description = %q{Ruby wrapper for Streamios api.}

  s.files         = Dir.glob("lib/**/*") + %w(Gemfile awesome.gemspec HISTORY README.rdoc)
  
  s.add_development_dependency("rspec", "~> 2.1.0")
end
