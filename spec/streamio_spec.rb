require 'spec_helper'

describe Streamio do
  it "should be configurable" do
    Streamio.username.should be_nil
    Streamio.password.should be_nil
    
    Streamio.configure do |config|
      config.username = "username"
      config.password = "password"
    end
    
    Streamio.username.should == "username"
    Streamio.password.should == "password"
  end
end
