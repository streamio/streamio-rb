module Streamio
  class Resource
    attr_reader :name

    def initialize(name)
      @name = name
      @resource_path = "/api/v1/#{@name}"

      uri = URI.parse(Streamio.protocol+Streamio.host)
      @net = Net::HTTP.new(uri.host, uri.port)
      @net.use_ssl = Streamio.use_ssl
      @net.verify_mode = OpenSSL::SSL::VERIFY_NONE if Streamio.skip_ssl_verification
    end

    def get(path, parameters = {})
      validate_and_return @net.request(net_request(Net::HTTP::Get, path, parameters))
    end

    def post(path, parameters = {})
      request_class = parameters.any? do |key, value|
        value.is_a?(File)
      end ? Net::HTTP::Post::Multipart : Net::HTTP::Post

      validate_and_return @net.request(net_request(request_class, path, parameters))
    end

    def put(path, parameters = {})
      validate_and_return @net.request(net_request(Net::HTTP::Put, path, parameters))
    end

    def delete(path)
      validate_and_return @net.request(net_request(Net::HTTP::Delete, path))
    end

    private
    def net_request(request_class, sub_path, parameters = {})
      path = @resource_path
      path << "/#{sub_path}" if sub_path

      if request_class == Net::HTTP::Get
        path << "?#{Rack::Utils.build_query(parameters)}" unless parameters.empty?
        req = request_class.new(path)
      elsif request_class == Net::HTTP::Post::Multipart
        parameters.each do |key, value|
          parameters[key] = UploadIO.new(value, "application/octet-stream", File.basename(value.path)) if value.is_a?(File)
          parameters[key] = value.join(", ") if value.is_a?(Array)
        end
        req = request_class.new(path, parameters)
      else
        req = request_class.new(path)
        req.body = Rack::Utils.build_query(parameters)
      end

      req.basic_auth(Streamio.username, Streamio.password)
      req["Accept"] = "application/json"
      req
    end

    def validate_and_return(response)
      raise Errors::Unauthorized if response.code.to_i == 401
      response
    end
  end
end
