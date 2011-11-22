require 'spec_helper'

module Streamio
  describe Playlist do
    it "should be a Streamio::Model" do
      Playlist.new.is_a?(Streamio::Model).should be_true
    end
    
    it "should use the playlists resource" do
      Playlist.resource.url.should == "#{Streamio.authenticated_api_base}/playlists"
    end
    
    it "should have certain creatable attributes" do
      Playlist.creatable_attributes.should == []
    end
    
    it "should have certain accessable attributes" do
      Playlist.accessable_attributes.should == %w(title tags order_by order_direction)
    end
    
    it "should have certain readable attributes" do
      Playlist.readable_attributes.should == %w(id created_at updated_at account_id)
    end
  end
end
