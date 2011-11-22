require "rest_client"
require "json"
require "time"

require "streamio/version"
require "streamio/model"
require "streamio/video"
require "streamio/image"
require "streamio/playlist"
require "streamio/encoding_profile"
require "streamio/upload"

module Streamio
  class << self
    attr_accessor :username
    attr_accessor :password
    attr_accessor :use_ssl
    attr_accessor :host
    
    # The idiomatic configure block for the Streamio gem. Basically a shortcut
    # for the Streamio module attributes.
    #
    # @example Configure your API username and password.
    #   Streamio.configure do |config|
    #     config.username = "my_awesome_account"
    #     config.password = "3633b4a027d74ead0038addff89550"
    #   end
    def configure
      yield self
    end
    
    def use_ssl
      return true if @use_ssl.nil?
      @use_ssl
    end
    alias :use_ssl? :use_ssl
    
    def protocol
      use_ssl? ? "https://" : "http://"
    end
    
    def host
      return "streamio.com" if @host.nil?
      @host
    end
    
    def authenticated_api_base
      "#{protocol}#{username}:#{password}@#{host}/api/v1"
    end
  end
end
