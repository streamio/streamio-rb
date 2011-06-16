# -*- encoding: utf-8 -*-
require 'spec_helper'

module Streamio
  describe EncodingProfile do
    before(:each) do
      apply_test_config
    end
    
    describe "attributes" do
      it "should be settable" do
        encoding_profile = EncodingProfile.new
        
        encoding_profile.title = "Test"
        encoding_profile.title.should == "Test"
        
        encoding_profile.tags = ["asdf", "qwer"]
        encoding_profile.tags.should == ["asdf", "qwer"]
        
        encoding_profile.width = 320
        encoding_profile.width.should == 320
        
        encoding_profile.desired_video_bitrate = 500
        encoding_profile.desired_video_bitrate.should == 500
        
        encoding_profile.frame_rate = 30
        encoding_profile.frame_rate.should == 30
        
        encoding_profile.audio_bitrate = 192
        encoding_profile.audio_bitrate.should == 192
        
        encoding_profile.audio_sample_rate = 22050
        encoding_profile.audio_sample_rate.should == 22050
        
        encoding_profile.audio_channels = 2
        encoding_profile.audio_channels.should == 2
      end
      
      it "should be settable through attributes hash" do
        encoding_profile = EncodingProfile.new :title => "Test", 
                                               :tags => ["asdf", "qwer"],
                                               :width => 320
        
        encoding_profile.title.should == "Test"
        encoding_profile.tags.should == ["asdf", "qwer"]
        encoding_profile.width.should == 320
      end
      
      it "should have default values" do
        encoding_profile = EncodingProfile.new
        
        encoding_profile.id.should be_nil
        encoding_profile.created_at.should be_nil
        encoding_profile.updated_at.should be_nil
        encoding_profile.title.should be_nil
        encoding_profile.tags.should == []
        encoding_profile.width.should be_nil
        encoding_profile.desired_video_bitrate.should be_nil
        encoding_profile.frame_rate.should be_nil
        encoding_profile.audio_bitrate.should be_nil
        encoding_profile.audio_sample_rate.should be_nil
        encoding_profile.audio_channels.should be_nil
      end
      
      it "should have pushable tags" do
        encoding_profile = EncodingProfile.new
        encoding_profile.tags.push "asdf"
        encoding_profile.tags.push "qwer"
        encoding_profile.tags.should == ["asdf", "qwer"]
      end
      
      it "should not be persisted" do
        EncodingProfile.new.should_not be_persisted
      end
      
      it "should not be destroyed" do
        EncodingProfile.new.should_not be_destroyed
      end
    end
    
    describe ".find" do
      context "with an existing encoding profile" do
        before(:each) do
          stub_request(:get, "#{Streamio.authenticated_api_base}/encoding_profiles/4b86857fbf4b982ac6000003").
            to_return(:body => File.read("#{fixture_path}/api/encoding_profiles/show.json"), :status => 200)

          @encoding_profile = EncodingProfile.find("4b86857fbf4b982ac6000003")
        end
        
        it "should make a GET request and assign all the attributes" do
          @encoding_profile.id.should == "4b86857fbf4b982ac6000003"
          @encoding_profile.title.should == "Test"
          @encoding_profile.tags.should == ["asdf", "qwer"]
          @encoding_profile.account_id.should == "4c50424cb35ea827c0000005"
          @encoding_profile.created_at.to_i.should == 1290521052
          @encoding_profile.updated_at.to_i.should == 1290521052
          @encoding_profile.frame_rate.should == 25.0
          @encoding_profile.audio_channels.should == 1
          @encoding_profile.audio_sample_rate.should == 22050
          @encoding_profile.audio_bitrate.should == 64
          @encoding_profile.desired_video_bitrate.should == 1000
          @encoding_profile.width.should == 450
        end
        
        it "should be persisted" do
          @encoding_profile.should be_persisted
        end
      end
    end
    
    describe ".all" do
      it "should make a GET request and populate an array" do
        stub_request(:get, "#{Streamio.authenticated_api_base}/encoding_profiles").
          to_return(:body => File.read("#{fixture_path}/api/encoding_profiles/all.json"), :status => 200)
        
        encoding_profiles = EncodingProfile.all
        
        encoding_profiles.length.should == 2
        encoding_profiles.first.should be_instance_of(EncodingProfile)
      end
      
      it "should pass on parameters as query string" do
        stub_request(:get, "#{Streamio.authenticated_api_base}/encoding_profiles?limit=3&order=created_at.asc&skip=2&tags=L%C3%B6rdags%20Party,symbol&title=Awesome").
          to_return(:body => File.read("#{fixture_path}/api/encoding_profiles/all.json"), :status => 200)
        
        encoding_profiles = EncodingProfile.all(:title => "Awesome",  :tags => ["Lördags Party", :symbol], :skip => 2, :limit => 3, :order => "created_at.asc")
        
        encoding_profiles.length.should == 2
        encoding_profiles.collect(&:class).uniq.should == [EncodingProfile]
      end
    end
    
    describe "#save" do
      # This spec passes but only on Ruby 1.9 because of the non random hash order
      it "should put accessable attributes when updating" do
        stub_request(:get, "#{Streamio.authenticated_api_base}/encoding_profiles/4b86857fbf4b982ac6000003").
          to_return(:body => File.read("#{fixture_path}/api/encoding_profiles/show.json"), :status => 200)
        
        @encoding_profile = EncodingProfile.find("4b86857fbf4b982ac6000003")
        
        attributes = { :title => "New Title",
                       :tags => ["new", "tags"],
                       :width => 450,
                       :desired_video_bitrate => 1000,
                       :frame_rate => 25.0,
                       :audio_bitrate => 64,
                       :audio_sample_rate => 22050,
                       :audio_channels => 2 }
        
        attributes.each do |key, value|
          @encoding_profile.send("#{key}=", value)
        end
         
        stub_request(:put, "#{Streamio.authenticated_api_base}/encoding_profiles/#{@encoding_profile.id}").
          with(:body => RestClient::Payload.generate(attributes).to_s).
          to_return(:status => 200)
          
        @encoding_profile.save
      end
      
      context "unpersisted with valid attributes" do
        before(:each) do
          stub_request(:post, "#{Streamio.authenticated_api_base}/encoding_profiles").
            to_return(:body => File.read("#{fixture_path}/api/encoding_profiles/create.json"), :status => 201)
        end
        
        it "should be true" do
          EncodingProfile.new.save.should === true
        end
        
        it "should refresh the object with attributes from the response" do
          encoding_profile = EncodingProfile.new          
          encoding_profile.save
          
          encoding_profile.id.should == "4b86857fbf4b982ac6000003"
          encoding_profile.title.should == "Test"
          encoding_profile.tags.should == ["asdf", "qwer"]
          encoding_profile.account_id.should == "4c50424cb35ea827c0000005"
          encoding_profile.created_at.to_i.should == 1290521052
          encoding_profile.updated_at.to_i.should == 1290521052
          encoding_profile.frame_rate.should == 25.0
          encoding_profile.audio_channels.should == 1
          encoding_profile.audio_sample_rate.should == 22050
          encoding_profile.audio_bitrate.should == 64
          encoding_profile.desired_video_bitrate.should == 1000
          encoding_profile.width.should == 450
        end
      end
      
      context "unpersisted with invalid attributes" do
        before(:each) do
          stub_request(:post, "#{Streamio.authenticated_api_base}/encoding_profiles").
            to_return(:body => File.read("#{fixture_path}/api/encoding_profiles/create_fail.json"), :status => 422)
        end
        
        it "should be false" do
          EncodingProfile.new.save.should be_false
        end
        
        it "should make validation errors availible" do
          encoding_profile = EncodingProfile.new
          encoding_profile.save
          encoding_profile.errors.should == {"title" => ["can't be blank"]}
        end
      end
      
      context "persisted with valid attributes" do
        before(:each) do
          stub_request(:get, "#{Streamio.authenticated_api_base}/encoding_profiles/4b86857fbf4b982ac6000003").
            to_return(:body => File.read("#{fixture_path}/api/encoding_profiles/show.json"), :status => 200)

          @encoding_profile = EncodingProfile.find("4b86857fbf4b982ac6000003")
          
          stub_request(:put, "#{Streamio.authenticated_api_base}/encoding_profiles/#{@encoding_profile.id}").
            to_return(:status => 200)
        end
        
        it "should be true" do
          @encoding_profile.save.should be_true
        end
      end
      
      context "persisted with invalid attributes" do
        before(:each) do
          stub_request(:get, "#{Streamio.authenticated_api_base}/encoding_profiles/4b86857fbf4b982ac6000003").
            to_return(:body => File.read("#{fixture_path}/api/encoding_profiles/show.json"), :status => 200)

          @encoding_profile = EncodingProfile.find("4b86857fbf4b982ac6000003")
          
          stub_request(:put, "#{Streamio.authenticated_api_base}/encoding_profiles/#{@encoding_profile.id}").
            to_return(:body => File.read("#{fixture_path}/api/encoding_profiles/update_fail.json"), :status => 422)
        end
        
        it "should be false" do
          @encoding_profile.save.should be_false
        end
        
        it "should make validation errors availible" do
          @encoding_profile.save
          @encoding_profile.errors.should == {"title" => ["can't be blank"]}
        end
      end
    end
    
    describe "#destroy" do
      before(:each) do
        stub_request(:get, "#{Streamio.authenticated_api_base}/encoding_profiles/4b86857fbf4b982ac6000003").
          to_return(:body => File.read("#{fixture_path}/api/encoding_profiles/show.json"), :status => 200)
        @encoding_profile = EncodingProfile.find("4b86857fbf4b982ac6000003")
        stub_request(:delete, "#{Streamio.authenticated_api_base}/encoding_profiles/4b86857fbf4b982ac6000003").
          to_return(:status => 200)
      end
      
      it "should run the delete request" do
        @encoding_profile.destroy
        WebMock.should have_requested(:delete, "#{Streamio.authenticated_api_base}/encoding_profiles/4b86857fbf4b982ac6000003")
      end
      
      it "should be true" do
        @encoding_profile.destroy.should be_true
      end
      
      it "should freeze the attributes" do
        @encoding_profile.destroy
        expect { @encoding_profile.title = "New Title" }.to raise_error("can't modify frozen hash")
      end
      
      it "should be destroyed" do
        @encoding_profile.destroy
        @encoding_profile.should be_destroyed
      end
    end
  end
end
