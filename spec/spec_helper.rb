require 'bundler'
Bundler.require

STREAMIO_USERNAME = "username"
STREAMIO_PASSWORD = "password"

require 'webmock/rspec'

def fixture_path
  @fixture_path ||= File.join(File.dirname(__FILE__), 'fixtures')
end

def apply_test_config
  Streamio.configure do |config|
    config.username = STREAMIO_USERNAME
    config.password = STREAMIO_PASSWORD
    config.use_ssl = false
    config.host = "localhost:3000"
  end
end

def reset_config
  Streamio.configure do |config|
    config.username = nil
    config.password = nil
    config.use_ssl = nil
    config.host = nil
  end
end