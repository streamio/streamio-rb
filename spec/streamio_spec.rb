require 'spec_helper'

describe Streamio do
  it "should be configurable" do
    Streamio.configure do |config|
      config.username = "awesome"
      config.password = "pazzword"
      config.use_ssl = false
      config.host = "localhost:3000"
    end
    
    Streamio.username.should == "awesome"
    Streamio.password.should == "pazzword"
    Streamio.use_ssl.should be_false
    Streamio.host.should == "localhost:3000"
  end
  
  describe ".authenticated_api_base" do
    it "should default to https://username:password@streamio.com/api/v1" do
      reset_config
      Streamio.username = "username"
      Streamio.password = "password"
      Streamio.authenticated_api_base.should == "https://username:password@streamio.com/api/v1"
    end
    
    it "should have overrideable defaults" do
      reset_config
      Streamio.configure do |config|
        config.username = "emanresu"
        config.password = "drowssap"
        config.use_ssl = false
        config.host = "localhost:3000"
      end
      Streamio.authenticated_api_base.should == "http://emanresu:drowssap@localhost:3000/api/v1"
    end
  end
end
