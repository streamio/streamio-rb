require "rest_client"
require "json"
require "time"

require "streamio/version"
require "streamio/model"
require "streamio/video"
require "streamio/image"

module Streamio
  class << self
    attr_accessor :username
    attr_accessor :password
    attr_accessor :use_ssl
    attr_accessor :host
    
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
