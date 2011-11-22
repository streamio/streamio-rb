# -*- encoding: utf-8 -*-
require 'spec_helper'

module Streamio
  describe Player do
    before(:each) do
      apply_test_config
    end
    
    it "should be a Streamio::Model" do
      Player.new.is_a?(Streamio::Model).should be_true
    end
    
    it "should use the players resource" do
      Player.resource.url.should == "#{Streamio.authenticated_api_base}/players"
    end
    
    it "should have certain creatable attributes" do
      Player.creatable_attributes.should == []
    end
    
    it "should have certain accessable attributes" do
      Player.accessable_attributes.should == %w(title tags width height skin loop autoplay enable_rtmp show_title show_play_pause_button show_elapsed_time show_seek_bar show_total_time show_volume_control show_full_screen_button google_analytics_property_id smartclip_preroll_url smartclip_html5_preroll_url playlist limit css)
    end
    
    it "should have certain readable attributes" do
      Player.readable_attributes.should == %w(id created_at updated_at account_id playlist_ids)
    end
  end
end
