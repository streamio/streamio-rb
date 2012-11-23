# -*- encoding: utf-8 -*-
require 'spec_helper'

module Streamio
  describe Video do
    before(:each) do
      apply_test_config
    end
    
    it "should be a Streamio::Model" do
      Video.new.is_a?(Streamio::Model).should be_true
    end
    
    it "should use the videos resource" do
      Video.resource.name.should == "videos"
    end
    
    it "should have certain creatable attributes" do
      Video.creatable_attributes.should == %w(file encoding_profile_ids encoding_profile_tags skip_default_encoding_profiles use_original_as_transcoding)
    end
    
    it "should have certain accessable attributes" do
      Video.accessable_attributes.should == %w(title description tags image_id)
    end
    
    it "should have certain readable attributes" do
      Video.readable_attributes.should == %w(id state progress aspect_ratio_multiplier plays duration created_at updated_at account_id transcodings original_video)
    end
    
    describe "#add_transcoding" do
      before(:each) do
        stub_request(:get, "#{Streamio.authenticated_api_base}/videos/4b86857fbf4b982ac6000003").
          to_return(:body => File.read("#{fixture_path}/api/videos/one.json"), :status => 200)
        @video = Video.find("4b86857fbf4b982ac6000003")
      end
    
      context "with valid parameters" do
        before(:each) do
          stub_request(:post, "#{Streamio.authenticated_api_base}/videos/4b86857fbf4b982ac6000003/transcodings").
            to_return(:status => 201)
        end
      
        it "should post to the videos transcodings" do
          @video.add_transcoding(:encoding_profile_id => "4b86857fbf4b982ac6000004")
          WebMock.should have_requested(:post, "#{Streamio.authenticated_api_base}/videos/4b86857fbf4b982ac6000003/transcodings").
            with(:body => "encoding_profile_id=4b86857fbf4b982ac6000004").once
        end
      
        it "should be true" do
          @video.add_transcoding(:encoding_profile_id => "4b86857fbf4b982ac6000004").should === true
        end
      
        it "should reload itself" do
          stub_request(:get, "#{Streamio.authenticated_api_base}/videos/4b86857fbf4b982ac6000003").
            to_return(:body => File.read("#{fixture_path}/api/videos/one_add_transcoding.json"), :status => 200)
          
          @video.add_transcoding(:encoding_profile_id => "4b86857fbf4b982ac6000004")
          @video.transcodings.length.should == 3
        end
      end
    
      context "with invalid parameters" do
        before(:each) do
          stub_request(:post, "#{Streamio.authenticated_api_base}/videos/4b86857fbf4b982ac6000003/transcodings").
            to_return(:status => 500)
        end
      
        it "should be false" do
          @video.add_transcoding({}).should === false
        end
      end
    end
  
    describe "#delete_transcoding" do
      before(:each) do
        stub_request(:get, "#{Streamio.authenticated_api_base}/videos/4b86857fbf4b982ac6000003").
          to_return(:body => File.read("#{fixture_path}/api/videos/one.json"), :status => 200)
        @video = Video.find("4b86857fbf4b982ac6000003")
      end
    
      context "with valid parameters" do
        before(:each) do
          stub_request(:delete, "#{Streamio.authenticated_api_base}/videos/4b86857fbf4b982ac6000003/transcodings/4cea850054129010f3000024").
            to_return(:status => 200)
        end
      
        it "should post to the videos transcodings" do
          @video.delete_transcoding("4cea850054129010f3000024")
          WebMock.should have_requested(:delete, "#{Streamio.authenticated_api_base}/videos/4b86857fbf4b982ac6000003/transcodings/4cea850054129010f3000024").once
        end
      
        it "should be true" do
          @video.delete_transcoding("4cea850054129010f3000024").should === true
        end
        
        it "should reload itself" do
          stub_request(:get, "#{Streamio.authenticated_api_base}/videos/4b86857fbf4b982ac6000003").
            to_return(:body => File.read("#{fixture_path}/api/videos/one_delete_transcoding.json"), :status => 200)
          
          @video.delete_transcoding("4cea850054129010f3000024")
          @video.transcodings.length.should == 1
        end
      end
    
      context "with invalid parameters" do
        before(:each) do
          stub_request(:delete, "#{Streamio.authenticated_api_base}/videos/4b86857fbf4b982ac6000003/transcodings/4b86857fbf4b982ac6000004").
            to_return(:status => 500)
        end
      
        it "should be false" do
          @video.delete_transcoding("4b86857fbf4b982ac6000004").should === false
        end
      end
    end
  end
end