# -*- encoding: utf-8 -*-
require 'spec_helper'

module Streamio
  describe Image do
    before(:each) do
      apply_test_config
    end
    
    it "should be a Streamio::Model" do
      Image.new.is_a?(Streamio::Model).should be_true
    end
    
    it "should use the images resource" do
      Image.resource.name.should == "images"
    end
    
    it "should have certain creatable attributes" do
      Image.creatable_attributes.should == %w(file)
    end
    
    it "should have certain accessable attributes" do
      Image.accessable_attributes.should == %w(title tags)
    end
    
    it "should have certain readable attributes" do
      Image.readable_attributes.should == %w(id created_at updated_at account_id transcodings)
    end
  end
end
