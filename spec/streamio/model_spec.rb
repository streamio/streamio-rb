# -*- encoding: utf-8 -*-
require 'spec_helper'

class Clip < Streamio::Model
  resource_name "clips"
  creatable_attributes %w(file)
  accessable_attributes %w(title description tags)
  readable_attributes %w(id state created_at updated_at account_id transcodings)
end

module Streamio
  describe Model do
    before(:each) do
      apply_test_config
    end
    
    describe "attributes" do
      it "should be settable" do
        clip = Clip.new
        
        clip.title = "Test"
        clip.title.should == "Test"
        
        clip.description = "Description"
        clip.description.should == "Description"
        
        clip.file = File.new("#{fixture_path}/awesome.mov")
        clip.file.path.should == "#{fixture_path}/awesome.mov"
        
        clip.tags = ["asdf", "qwer"]
        clip.tags.should == ["asdf", "qwer"]
      end
      
      it "should be settable through attributes hash" do
        clip = Clip.new :title => "Test", 
                        :description => "Description", 
                        :file => File.new("#{fixture_path}/awesome.mov"),
                        :tags => ["asdf", "qwer"]
        
        clip.title.should == "Test"
        clip.description.should == "Description"
        clip.file.path.should == "#{fixture_path}/awesome.mov"
        clip.tags.should == ["asdf", "qwer"]
      end
      
      it "should have default values" do
        clip = Clip.new
        
        clip.id.should be_nil
        clip.created_at.should be_nil
        clip.updated_at.should be_nil
        clip.title.should be_nil
        clip.description.should be_nil
        clip.file.should be_nil
        clip.tags.should == []
      end
      
      it "should have pushable tags" do
        clip = Clip.new
        clip.tags.push "asdf"
        clip.tags.push "qwer"
        clip.tags.should == ["asdf", "qwer"]
      end
    end
    
    it "should not be persisted by default" do
      Clip.new.should_not be_persisted
    end
    
    it "should not be destroyed by default" do
      Clip.new.should_not be_destroyed
    end
    
    describe ".find" do
      context "with an existing clip" do
        before(:each) do
          stub_request(:get, "#{Streamio.authenticated_api_base}/clips/4c8f810eb35ea84de000000c").
            to_return(:body => File.read("#{fixture_path}/api/clips/one.json"), :status => 200)

          @clip = Clip.find("4c8f810eb35ea84de000000c")
        end
        
        it "should make a GET request and assign all the attributes" do
          @clip.id.should == "4c8f810eb35ea84de000000c"
          @clip.title.should == "Awesome"
          @clip.tags.should == ["one", "two"]
          @clip.description.should == "An awesome clip"
          @clip.state.should == "pending"
          @clip.created_at.to_i.should == 1286527262
          @clip.updated_at.to_i.should == 1286537113
        end
        
        it "should be persisted" do
          @clip.should be_persisted
        end
      end
    end
    
    describe ".all" do
      it "should make a GET request and populate an array" do
        stub_request(:get, "#{Streamio.authenticated_api_base}/clips").
          to_return(:body => File.read("#{fixture_path}/api/clips/all.json"), :status => 200)
        
        clips = Clip.all
        
        clips.length.should == 2
        clips.first.should be_instance_of(Clip)
      end
      
      it "should pass on parameters as query string" do
        stub_request(:get, "#{Streamio.authenticated_api_base}/clips?limit=3&order=created_at.asc&skip=2&tags=L%C3%B6rdags%20Party,symbol&title=Awesome").
          to_return(:body => File.read("#{fixture_path}/api/clips/all.json"), :status => 200)
        
        clips = Clip.all(:title => "Awesome",  :tags => ["Lördags Party", :symbol], :skip => 2, :limit => 3, :order => "created_at.asc")
        
        clips.length.should == 2
        clips.collect(&:class).uniq.should == [Clip]
      end
    end
    
    describe ".destroy" do
      before(:each) do
        stub_request(:delete, "#{Streamio.authenticated_api_base}/clips/4c8f810eb35ea84de000000c").
          to_return(:status => 200)
      end
      
      it "should run the delete request" do
        Clip.destroy("4c8f810eb35ea84de000000c")
        WebMock.should have_requested(:delete, "#{Streamio.authenticated_api_base}/clips/4c8f810eb35ea84de000000c")
      end
      
      it "should be true" do
        Clip.destroy("4c8f810eb35ea84de000000c").should == true
      end
    end
    
    describe "#save" do
      # This does not work because the Payload is generated differently every time and some strange encoding troubles
      pending "should post creatable and accessable attributes when persisting" do
        attributes = { :title => "Awesome",
                       :description => "An awesome clip",
                       :file => File.new("#{fixture_path}/awesome.mov"),
                       :tags => ["one", "two"] }
        
        stub_request(:post, "#{Streamio.authenticated_api_base}/clips").
          with(:body => RestClient::Payload.generate(attributes).to_s).
          to_return(:body => File.read("#{fixture_path}/api/clips/one.json"), :status => 201)
        
        attributes[:file] = File.new("#{fixture_path}/awesome.mov")
        
        clip = Clip.new(attributes)
        clip.save
      end
      
      # This spec passes but only on Ruby 1.9 because of the non random hash order
      it "should put accessable attributes when updating" do
        stub_request(:get, "#{Streamio.authenticated_api_base}/clips/4c8f810eb35ea84de000000c").
          to_return(:body => File.read("#{fixture_path}/api/clips/one.json"), :status => 200)
        
        @clip = Clip.find("4c8f810eb35ea84de000000c")
        
        attributes = { :title => "New Title",
                       :description => "New Description",
                       :tags => ["new", "tags"] }
        
        attributes.each do |key, value|
          @clip.send("#{key}=", value)
        end
        
        stub_request(:put, "#{Streamio.authenticated_api_base}/clips/#{@clip.id}").
          to_return(:status => 200)
          
        @clip.save
        
        WebMock.should have_requested(:put, "#{Streamio.authenticated_api_base}/clips/#{@clip.id}").
          with(:body => RestClient::Payload.generate(attributes).to_s)
      end
      
      context "unpersisted with valid attributes" do
        before(:each) do
          stub_request(:post, "#{Streamio.authenticated_api_base}/clips").
            to_return(:body => File.read("#{fixture_path}/api/clips/one.json"), :status => 201)
        end
        
        it "should be true" do
          Clip.new.save.should === true
        end
        
        it "should refresh the object with attributes from the response" do
          clip = Clip.new          
          clip.save
          
          clip.id.should == "4c8f810eb35ea84de000000c"
          clip.title.should == "Awesome"
          clip.description.should == "An awesome clip"
          clip.file.should be_nil
          clip.tags.should == ["one", "two"]
          clip.state.should == "pending"
          clip.account_id.should == "4c8f810eb35ea84de000000e"
          clip.created_at.to_i.should == 1286527262
          clip.updated_at.to_i.should == 1286537113
        end
        
        it "should populate the transcodings array" do
          clip = Clip.new
          clip.save
          
          clip.transcodings.collect do |transcoding|
            transcoding["id"]
          end.should == %w(4cea850054129010f3000023 4cea850054129010f3000024)
        end
      end
      
      context "unpersisted with invalid attributes" do
        before(:each) do
          stub_request(:post, "#{Streamio.authenticated_api_base}/clips").
            to_return(:body => File.read("#{fixture_path}/api/clips/create_fail.json"), :status => 422)
        end
        
        it "should be false" do
          Clip.new.save.should be_false
        end
        
        it "should make validation errors availible" do
          clip = Clip.new
          clip.save
          clip.errors.should == {"file" => ["is not a valid clip file"]}
        end
      end
      
      context "persisted with valid attributes" do
        before(:each) do
          stub_request(:get, "#{Streamio.authenticated_api_base}/clips/4c8f810eb35ea84de000000c").
            to_return(:body => File.read("#{fixture_path}/api/clips/one.json"), :status => 200)

          @clip = Clip.find("4c8f810eb35ea84de000000c")
          
          stub_request(:put, "#{Streamio.authenticated_api_base}/clips/#{@clip.id}").
            to_return(:status => 200)
        end
        
        it "should be true" do
          @clip.save.should be_true
        end
      end
      
      context "persisted with invalid attributes" do
        before(:each) do
          stub_request(:get, "#{Streamio.authenticated_api_base}/clips/4c8f810eb35ea84de000000c").
            to_return(:body => File.read("#{fixture_path}/api/clips/one.json"), :status => 200)

          @clip = Clip.find("4c8f810eb35ea84de000000c")
          
          stub_request(:put, "#{Streamio.authenticated_api_base}/clips/#{@clip.id}").
            to_return(:body => File.read("#{fixture_path}/api/clips/update_fail.json"), :status => 422)
        end
        
        it "should be false" do
          @clip.save.should be_false
        end
        
        it "should make validation errors availible" do
          @clip.save
          @clip.errors.should == {"title" => ["can't be blank"]}
        end
      end
    end
    
    describe "#destroy" do
      before(:each) do
        stub_request(:get, "#{Streamio.authenticated_api_base}/clips/4c8f810eb35ea84de000000c").
          to_return(:body => File.read("#{fixture_path}/api/clips/one.json"), :status => 200)
        @clip = Clip.find("4c8f810eb35ea84de000000c")
        stub_request(:delete, "#{Streamio.authenticated_api_base}/clips/4c8f810eb35ea84de000000c").
          to_return(:status => 200)
      end
      
      it "should run the delete request" do
        @clip.destroy
        WebMock.should have_requested(:delete, "#{Streamio.authenticated_api_base}/clips/4c8f810eb35ea84de000000c")
      end
      
      it "should be true" do
        @clip.destroy.should be_true
      end
      
      it "should freeze the attributes" do
        @clip.destroy
        expect { @clip.title = "New Title" }.to raise_error("can't modify frozen hash")
      end
      
      it "should be destroyed" do
        @clip.destroy
        @clip.should be_destroyed
      end
    end
    
    describe "#reload" do
      before(:each) do
        stub_request(:get, "#{Streamio.authenticated_api_base}/clips/4c8f810eb35ea84de000000c").
          to_return(:body => File.read("#{fixture_path}/api/clips/one.json"), :status => 200)
        @clip = Clip.find("4c8f810eb35ea84de000000c")

        stub_request(:get, "#{Streamio.authenticated_api_base}/clips/4c8f810eb35ea84de000000c").
          to_return(:body => File.read("#{fixture_path}/api/clips/one_reload.json"), :status => 200)
      end
      
      it "should return self" do
        @clip.reload.should == @clip
      end
      
      it "should update the resource with its remote state" do
        @clip.reload

        @clip.title.should == "Awesome Changed"
        @clip.description.should == "A really awesome clip"
        @clip.updated_at.to_i.should == 1289215513
        @clip.state.should == "ready"
        @clip.transcodings.collect do |transcoding|
          transcoding["id"] 
        end.should == %w(4cea850054129010f3000023 4cea850054129010f3000024 4cea850054129010f3000025)
      end
    end
  end
end
