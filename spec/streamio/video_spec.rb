# -*- encoding: utf-8 -*-
require 'spec_helper'

module Streamio
  describe Video do
    before(:each) do
      apply_test_config
    end
    
    describe "attributes" do
      it "should be settable" do
        video = Video.new
        
        video.title = "Test"
        video.title.should == "Test"
        
        video.description = "Description"
        video.description.should == "Description"
        
        video.file = File.new("#{fixture_path}/awesome.mov")
        video.file.path.should == "#{fixture_path}/awesome.mov"
        
        video.tags = ["asdf", "qwer"]
        video.tags.should == ["asdf", "qwer"]
      end
      
      it "should be settable through attributes hash" do
        video = Video.new(:title => "Test", 
                          :description => "Description", 
                          :file => File.new("#{fixture_path}/awesome.mov"),
                          :tags => ["asdf", "qwer"])
        
        video.title.should == "Test"
        video.description.should == "Description"
        video.file.path.should == "#{fixture_path}/awesome.mov"
        video.tags.should == ["asdf", "qwer"]
      end
      
      it "should have default values" do
        video = Video.new
        
        video.id.should be_nil
        video.created_at.should be_nil
        video.updated_at.should be_nil
        video.title.should be_nil
        video.description.should be_nil
        video.file.should be_nil
        video.tags.should == []
      end
      
      it "should have pushable tags" do
        video = Video.new
        video.tags.push "asdf"
        video.tags.push "qwer"
        video.tags.should == ["asdf", "qwer"]
      end
      
      it "should not be persisted" do
        Video.new.should_not be_persisted
      end
      
      it "should not be destroyed" do
        Video.new.should_not be_destroyed
      end
    end
    
    describe ".find" do
      context "with an existing video" do
        before(:each) do
          stub_request(:get, "#{Streamio.authenticated_api_base}/videos/4b86857fbf4b982ac6000003").
            to_return(:body => File.read("#{fixture_path}/api/videos/show.json"), :status => 200)

          @video = Video.find("4b86857fbf4b982ac6000003")
        end
        
        it "should make a GET request and assign all the attributes" do
          @video.id.should == "4b86857fbf4b982ac6000003"
          @video.title.should == "Awesome"
          @video.tags.should == ["hd", "sweet"]
          @video.description.should == "My awesome video."
          @video.duration.should == 185.5
          @video.plays.should == 123
          @video.state.should == "ready"
          @video.progress.should == 1.0
          @video.created_at.to_i.should == 1267107199
          @video.updated_at.to_i.should == 1267714850
          @video.aspect_ratio_multiplier.should == 1.33333333333333
        end
        
        it "should be persisted" do
          @video.should be_persisted
        end
      end
    end
    
    describe ".all" do
      it "should make a GET request and populate an array" do
        stub_request(:get, "#{Streamio.authenticated_api_base}/videos").
          to_return(:body => File.read("#{fixture_path}/api/videos/all.json"), :status => 200)
        
        videos = Video.all
        
        videos.length.should == 5
        videos.first.should be_instance_of(Video)
      end
      
      it "should pass on parameters as query string" do
        stub_request(:get, "#{Streamio.authenticated_api_base}/videos?limit=3&order=created_at.asc&skip=2&tags=L%C3%B6rdags%20Party,symbol&title=Awesome").
          to_return(:body => File.read("#{fixture_path}/api/videos/all.json"), :status => 200)
        
        videos = Video.all(:title => "Awesome",  :tags => ["Lördags Party", :symbol], :skip => 2, :limit => 3, :order => "created_at.asc")
        
        videos.length.should == 5
        videos.first.should be_instance_of(Video)
      end
    end
    
    describe "#save" do
      context "unpersisted with valid attributes" do
        before(:each) do
          stub_request(:post, "#{Streamio.authenticated_api_base}/videos").
            to_return(:body => File.read("#{fixture_path}/api/videos/create.json"), :status => 201)
        end
        
        it "should be true" do
          Video.new.save.should === true
        end
        
        it "should refresh the object with attributes from the response" do
          video = Video.new          
          video.save
          
          video.id.should == "4b86857fbf4b982ac6000003"
          video.title.should == "Test"
          video.description.should == "Description"
          video.file.should be_nil
          video.tags.should == ["asdf", "qwer"]
          video.aspect_ratio_multiplier.should == 1.33333333333333
          video.duration.should == 10
          video.state.should == "pending"
          video.progress.should == 0.0
          video.account_id.should == "4c50424cb35ea827c0000005"
          video.created_at.to_i.should == 1267107199
          video.updated_at.to_i.should == 1267107199
          video.plays.should == 0
          video.image_id.should == nil
        end
      end
      
      context "unpersisted with invalid attributes" do
        before(:each) do
          stub_request(:post, "#{Streamio.authenticated_api_base}/videos").
            to_return(:body => File.read("#{fixture_path}/api/videos/create_fail.json"), :status => 422)
        end
        
        it "should be false" do
          Video.new.save.should be_false
        end
        
        it "should make validation errors availible" do
          video = Video.new
          video.save
          video.errors.should == {"file" => ["is not a valid video file"]}
        end
      end
      
      context "persisted with valid attributes" do
        before(:each) do
          stub_request(:get, "#{Streamio.authenticated_api_base}/videos/4b86857fbf4b982ac6000003").
            to_return(:body => File.read("#{fixture_path}/api/videos/show.json"), :status => 200)

          @video = Video.find("4b86857fbf4b982ac6000003")
          
          stub_request(:put, "#{Streamio.authenticated_api_base}/videos/#{@video.id}").
            to_return(:status => 200)
        end
        
        it "should be true" do
          @video.save.should be_true
        end
      end
      
      context "persisted with invalid attributes" do
        before(:each) do
          stub_request(:get, "#{Streamio.authenticated_api_base}/videos/4b86857fbf4b982ac6000003").
            to_return(:body => File.read("#{fixture_path}/api/videos/show.json"), :status => 200)

          @video = Video.find("4b86857fbf4b982ac6000003")
          
          stub_request(:put, "#{Streamio.authenticated_api_base}/videos/#{@video.id}").
            to_return(:body => File.read("#{fixture_path}/api/videos/update_fail.json"), :status => 422)
        end
        
        it "should be false" do
          @video.save.should be_false
        end
        
        it "should make validation errors availible" do
          @video.save
          @video.errors.should == {"title" => ["can't be blank"]}
        end
      end
    end
    
    describe "#destroy" do
      before(:each) do
        stub_request(:get, "#{Streamio.authenticated_api_base}/videos/4b86857fbf4b982ac6000003").
          to_return(:body => File.read("#{fixture_path}/api/videos/show.json"), :status => 200)
        @video = Video.find("4b86857fbf4b982ac6000003")
        stub_request(:delete, "#{Streamio.authenticated_api_base}/videos/4b86857fbf4b982ac6000003").
          to_return(:status => 200)
      end
      
      it "should run the delete request" do
        @video.destroy
        WebMock.should have_requested(:delete, "#{Streamio.authenticated_api_base}/videos/4b86857fbf4b982ac6000003")
      end
      
      it "should be true" do
        @video.destroy.should be_true
      end
      
      it "should freeze the attributes" do
        @video.destroy
        expect { @video.title = "New Title" }.to raise_error(RuntimeError, "can't modify frozen hash")
      end
      
      it "should be destroyed" do
        @video.destroy
        @video.should be_destroyed
      end
    end
  end
end
