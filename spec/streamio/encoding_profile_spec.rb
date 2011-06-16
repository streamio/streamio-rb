# -*- encoding: utf-8 -*-
require 'spec_helper'

module Streamio
  describe EncodingProfile do
    before(:each) do
      apply_test_config
    end
    
    it "should be a Streamio::Model" do
      EncodingProfile.new.is_a?(Streamio::Model).should be_true
    end
    
    it "should use the encoding_profiles resource" do
      EncodingProfile.resource.url.should == "#{Streamio.authenticated_api_base}/encoding_profiles"
    end
    
    it "should have certain creatable attributes" do
      EncodingProfile.creatable_attributes.should == []
    end
    
    it "should have certain accessable attributes" do
      EncodingProfile.accessable_attributes.should == %w(title tags width desired_video_bitrate frame_rate audio_bitrate audio_sample_rate audio_channels)
    end
    
    it "should have certain readable attributes" do
      EncodingProfile.readable_attributes.should == %w(id created_at updated_at account_id)
    end
  end
end
