The Streamio Gem
================

Official ruby wrapper for the http://streamio.com API. Integrating video in your application has never been more awesome.

Installation
------------

``` bash
gem install streamio
```
    
Usage
-----

Load it.

``` ruby
require 'rubygems'
require 'streamio'
```
  
Configure it.

``` ruby
Streamio.configure do |config|
  config.username = "your_account_name"
  config.password = "your_api_private_key"
end
```

Use it.

``` ruby
# Fetch an array of videos
videos = Streamio::Video.all

# Pass in parameters as specified in the API docs
# This fetches the 5 most played videos tagged with Nature or Sports
videos = Streamio::Video.all(:tags => ["Nature", "Sports"], :limit => 5, :order => "plays.desc")

# Find a video by id
video = Streamio::Video.find("4c57f3975412901427000005")

# Create a video
video = Streamio::Video.new
video.save # false
video.errors # {:file => ["can't be blank"]}
video.file = File.new("my_awesome_video.mov")
video.save # true

Video.count # 23
Video.count(:tags => "Awesome") # 12
```

Same principles work for the other available models (Image, EncodingProfile, Player, Playlist and Upload).

More Documentation
------------------

YARDoc is avaible here:
http://rubydoc.info/gems/streamio

Please refer to the official Streamio API Documentation for details on parameters etc:
http://streamio.com/api/docs
