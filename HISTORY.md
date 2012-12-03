# 1.0.4 2012-12-03

* Add proper handling of authorization by raising Streamio::Errors::Unauthorized when using wrong username/password.

# 1.0.3 2012-12-03

* Fix ruby 1.8 compatability by avoiding use of define_singleton_method.

# 1.0.2 2012-11-26

* Replaced httpclient with net/http + multipart-post to avoid timeouts on file posting.

# 1.0.1 2012-11-23

* Loosend multi_json dependency version to conform with other ruby gems.
* Updated some development dependencies.

# 1.0.0 2012-11-23

* Replaced rest-client dependency with httpclient to support large file uploads.

# 0.9.2 2012-11-06

* Video#original_video accessor

# 0.9.1 2012-05-02

* Audio model
* Bumped multi_json dependency version

# 0.9.0 2011-12-01

* Use `multi_json` gem to handle JSON parsing for maximum backend compatibility.

# 0.8.0 2011-11-22

* Player model
* Playlist model
* All models got .count action

# 0.7.0 2011-06-17

* Upload model

# 0.6.0 2011-06-17

* Model.create
* Model.destroy
* Model#reload
* Video #add_transcoding and #delete_transcoding now reloads the video instance
* Some refactoring behind the scenes

# 0.5.1 2011-06-16

* Added lots of (YARD style) documentation and updated README

# 0.5.0 2011-06-15

* Basic api functionality for Videos, Images and Encoding Profiles
