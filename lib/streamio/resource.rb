module Streamio
  class Resource
    attr_reader :name

    def initialize(name)
      @name = name
      @client = HTTPClient.new
      @client.set_auth("#{Streamio.protocol}#{Streamio.host}", Streamio.username, Streamio.password)
    end

    def get(path, parameters = {})
      @client.get(url_for(path), parameters.empty? ? nil : parameters)
    end

    def post(path, parameters = {})
      @client.post(url_for(path), parameters)
    end

    def put(path, parameters = {})
      @client.put(url_for(path), parameters)
    end

    def delete(path)
      @client.delete(url_for(path))
    end

    private
    def url_for(path = nil)
      suffix = path ? "/#{path}" : ""
      "#{Streamio.authenticated_api_base}/#{@name}#{suffix}"
    end
  end
end
