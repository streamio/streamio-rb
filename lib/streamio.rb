module Streamio
  class << self
    attr_accessor :username
    attr_accessor :password
    
    def configure
      yield self
    end
  end
end
