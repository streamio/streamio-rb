require 'spec_helper'

module Streamio
  describe Upload do
    it "should be a Streamio::Model" do
      Upload.new.is_a?(Streamio::Model).should be_true
    end
    
    it "should use the uploads resource" do
      Upload.resource.url.should == "#{Streamio.authenticated_api_base}/uploads"
    end
    
    it "should have certain creatable attributes" do
      Upload.creatable_attributes.should == []
    end
    
    it "should have certain accessable attributes" do
      Upload.accessable_attributes.should == %w(title tags)
    end
    
    it "should have certain readable attributes" do
      Upload.readable_attributes.should == %w(id created_at updated_at account_id)
    end
  end
end
