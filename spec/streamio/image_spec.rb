# -*- encoding: utf-8 -*-
require 'spec_helper'

module Streamio
  describe Image do
    before(:each) do
      apply_test_config
    end
    
    describe "attributes" do
      it "should be settable" do
        image = Image.new
        
        image.title = "Test"
        image.title.should == "Test"
        
        image.file = File.new("#{fixture_path}/awesome.jpg")
        image.file.path.should == "#{fixture_path}/awesome.jpg"
        
        image.tags = ["asdf", "qwer"]
        image.tags.should == ["asdf", "qwer"]
      end
      
      it "should be settable through attributes hash" do
        image = Image.new(:title => "Test", 
                          :file => File.new("#{fixture_path}/awesome.jpg"),
                          :tags => ["asdf", "qwer"])
        
        image.title.should == "Test"
        image.file.path.should == "#{fixture_path}/awesome.jpg"
        image.tags.should == ["asdf", "qwer"]
      end
      
      it "should have default values" do
        image = Image.new
        
        image.id.should be_nil
        image.created_at.should be_nil
        image.updated_at.should be_nil
        image.title.should be_nil
        image.file.should be_nil
        image.tags.should == []
      end
      
      it "should have pushable tags" do
        image = Image.new
        image.tags.push "asdf"
        image.tags.push "qwer"
        image.tags.should == ["asdf", "qwer"]
      end
      
      it "should not be persisted" do
        Image.new.should_not be_persisted
      end
      
      it "should not be destroyed" do
        Image.new.should_not be_destroyed
      end
    end
    
    describe ".find" do
      context "with an existing image" do
        before(:each) do
          stub_request(:get, "#{Streamio.authenticated_api_base}/images/4b86857fbf4b982ac6000003").
            to_return(:body => File.read("#{fixture_path}/api/images/show.json"), :status => 200)

          @image = Image.find("4b86857fbf4b982ac6000003")
        end
        
        it "should make a GET request and assign all the attributes" do
          @image.id.should == "4b86857fbf4b982ac6000003"
          @image.title.should == "Awesome"
          @image.tags.should == ["green", "blue"]
          @image.created_at.to_i.should == 1282748694
          @image.updated_at.to_i.should == 1282748694
        end
        
        it "should be persisted" do
          @image.should be_persisted
        end
      end
    end
    
    describe ".all" do
      it "should make a GET request and populate an array" do
        stub_request(:get, "#{Streamio.authenticated_api_base}/images").
          to_return(:body => File.read("#{fixture_path}/api/images/all.json"), :status => 200)
        
        images = Image.all
        
        images.length.should == 2
        images.first.should be_instance_of(Image)
      end
      
      it "should pass on parameters as query string" do
        stub_request(:get, "#{Streamio.authenticated_api_base}/images?limit=3&order=created_at.asc&skip=2&tags=L%C3%B6rdags%20Party,symbol&title=Awesome").
          to_return(:body => File.read("#{fixture_path}/api/images/all.json"), :status => 200)
        
        images = Image.all(:title => "Awesome",  :tags => ["Lördags Party", :symbol], :skip => 2, :limit => 3, :order => "created_at.asc")
        
        images.length.should == 2
        images.collect(&:class).uniq.should == [Image]
      end
    end
    
    describe "#save" do
      # This does not work because the Payload is generated differently every time and some strange encoding troubles
      pending "should post creatable and accessable attributes when persisting" do
        attributes = { :title => "Title",
                       :file => File.new("#{fixture_path}/awesome.jpg"),
                       :tags => ["some", "tags"] }
        
        stub_request(:post, "#{Streamio.authenticated_api_base}/images").
          with(:body => RestClient::Payload.generate(attributes).to_s).
          to_return(:body => File.read("#{fixture_path}/api/images/create.json"), :status => 201)
        
        attributes[:file] = File.new("#{fixture_path}/awesome.jpg")
        
        image = Image.new(attributes)
        image.save
      end
      
      # This spec passes but only on Ruby 1.9 because of the non random hash order
      it "should put accessable attributes when updating" do
        stub_request(:get, "#{Streamio.authenticated_api_base}/images/4b86857fbf4b982ac6000003").
          to_return(:body => File.read("#{fixture_path}/api/images/show.json"), :status => 200)
        
        @image = Image.find("4b86857fbf4b982ac6000003")
        
        attributes = { :title => "New Title",
                       :tags => ["new", "tags"] }
        
        attributes.each do |key, value|
          @image.send("#{key}=", value)
        end
        
        stub_request(:put, "#{Streamio.authenticated_api_base}/images/#{@image.id}").
          with(:body => RestClient::Payload.generate(attributes).to_s).
          to_return(:status => 200)
          
        @image.save
      end
      
      context "unpersisted with valid attributes" do
        before(:each) do
          stub_request(:post, "#{Streamio.authenticated_api_base}/images").
            to_return(:body => File.read("#{fixture_path}/api/images/create.json"), :status => 201)
        end
        
        it "should be true" do
          Image.new.save.should === true
        end
        
        it "should refresh the object with attributes from the response" do
          image = Image.new          
          image.save
          
          image.id.should == "4b86857fbf4b982ac6000003"
          image.title.should == "awesome.jpg"
          image.file.should be_nil
          image.tags.should == ["green", "blue"]
          image.account_id.should == "4c50424cb35ea827c0000005"
          image.created_at.to_i.should == 1282748694
          image.updated_at.to_i.should == 1282748694
        end
        
        it "should populate the transcodings array" do
          image = Image.new
          image.save
          
          image.transcodings.collect do |transcoding|
            transcoding["title"]
          end.should == ["normal", "thumb", "original"]
        end
      end
      
      context "unpersisted with invalid attributes" do
        before(:each) do
          stub_request(:post, "#{Streamio.authenticated_api_base}/images").
            to_return(:body => File.read("#{fixture_path}/api/images/create_fail.json"), :status => 422)
        end
        
        it "should be false" do
          Image.new.save.should be_false
        end
        
        it "should make validation errors availible" do
          image = Image.new
          image.save
          image.errors.should == {"file" => ["is not a valid image file"]}
        end
      end
      
      context "persisted with valid attributes" do
        before(:each) do
          stub_request(:get, "#{Streamio.authenticated_api_base}/images/4b86857fbf4b982ac6000003").
            to_return(:body => File.read("#{fixture_path}/api/images/show.json"), :status => 200)

          @image = Image.find("4b86857fbf4b982ac6000003")
          
          stub_request(:put, "#{Streamio.authenticated_api_base}/images/#{@image.id}").
            to_return(:status => 200)
        end
        
        it "should be true" do
          @image.save.should be_true
        end
      end
      
      context "persisted with invalid attributes" do
        before(:each) do
          stub_request(:get, "#{Streamio.authenticated_api_base}/images/4b86857fbf4b982ac6000003").
            to_return(:body => File.read("#{fixture_path}/api/images/show.json"), :status => 200)

          @image = Image.find("4b86857fbf4b982ac6000003")
          
          stub_request(:put, "#{Streamio.authenticated_api_base}/images/#{@image.id}").
            to_return(:body => File.read("#{fixture_path}/api/images/update_fail.json"), :status => 422)
        end
        
        it "should be false" do
          @image.save.should be_false
        end
        
        it "should make validation errors availible" do
          @image.save
          @image.errors.should == {"title" => ["can't be blank"]}
        end
      end
    end
    
    describe "#destroy" do
      before(:each) do
        stub_request(:get, "#{Streamio.authenticated_api_base}/images/4b86857fbf4b982ac6000003").
          to_return(:body => File.read("#{fixture_path}/api/images/show.json"), :status => 200)
        @image = Image.find("4b86857fbf4b982ac6000003")
        stub_request(:delete, "#{Streamio.authenticated_api_base}/images/4b86857fbf4b982ac6000003").
          to_return(:status => 200)
      end
      
      it "should run the delete request" do
        @image.destroy
        WebMock.should have_requested(:delete, "#{Streamio.authenticated_api_base}/images/4b86857fbf4b982ac6000003")
      end
      
      it "should be true" do
        @image.destroy.should be_true
      end
      
      it "should freeze the attributes" do
        @image.destroy
        expect { @image.title = "New Title" }.to raise_error("can't modify frozen hash")
      end
      
      it "should be destroyed" do
        @image.destroy
        @image.should be_destroyed
      end
    end
  end
end
