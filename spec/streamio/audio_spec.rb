# -*- encoding: utf-8 -*-
require 'spec_helper'

module Streamio
  describe Audio do
    before(:each) do
      apply_test_config
    end
    
    it "should be a Streamio::Model" do
      Audio.new.is_a?(Streamio::Model).should be_true
    end
    
    it "should use the videos resource" do
      Audio.resource.name.should == "audios"
    end
    
    it "should have certain creatable attributes" do
      Audio.creatable_attributes.should == %w(file)
    end
    
    it "should have certain accessable attributes" do
      Audio.accessable_attributes.should == %w(title description tags)
    end
    
    it "should have certain readable attributes" do
      Audio.readable_attributes.should == %w(id state progress plays duration created_at updated_at account_id transcodings)
    end
  end
end