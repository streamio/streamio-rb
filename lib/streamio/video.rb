module Streamio
  class Video
    class << self
      def resource
        RestClient::Resource.new("#{Streamio.authenticated_api_base}/videos", :headers => {:accept => :json})
      end
      
      def find(id)
        parse_response(resource["#{id}"].get)
      end
      
      def all(parameters = {})
        sanitize_parameters(parameters)
        parse_response(resource.get(:params => parameters))
      end
      
      private
      def parse_response(response)
        response = JSON.parse(response.body)
        if response.instance_of?(Array)
          response.collect do |attributes|
            new(attributes)
          end
        else
          new(response)
        end
      end
      
      def sanitize_parameters(params)
        params.each do |key, value|
          params[key] = value.join(",") if value.instance_of?(Array)
        end
      end
    end
    
    CREATEABLE_ATTRIBUTES = %w(file encoding_profile_ids encoding_profile_tags skip_default_encoding_profiles use_original_as_transcoding)
    ACCESSABLE_ATTRIBUTES = %w(title description tags image_id)
    READABLE_ATTRIBUTES = %w(id state progress aspect_ratio_multiplier plays duration created_at updated_at account_id transcodings)
    
    attr_reader :attributes, :errors
    
    def initialize(attributes = {})
      @errors = {}
      @attributes = attributes.inject(Hash.new) do |options, (key, value)|
        options[key.to_s] = value
        options
      end
    end
    
    def persisted?
      !destroyed? && !id.nil?
    end
    
    def destroyed?
      @attributes.frozen?
    end
    
    def save
      if persisted?
        update
      else  
        persist
      end
    rescue RestClient::UnprocessableEntity => e
      @errors = JSON.parse(e.response)
      false
    end
    
    def destroy
      self.class.resource[id].delete
      @attributes.freeze
      true
    end
    
    (CREATEABLE_ATTRIBUTES + ACCESSABLE_ATTRIBUTES + READABLE_ATTRIBUTES).each do |attribute|
      define_method(attribute) do
        @attributes[attribute]
      end
    end
    
    (CREATEABLE_ATTRIBUTES + ACCESSABLE_ATTRIBUTES).each do |attribute|
      define_method("#{attribute}=") do |value|
        @attributes[attribute] = value
      end
    end
    
    def tags
      @attributes["tags"] = [] if @attributes["tags"].nil?
      @attributes["tags"]
    end
    
    def created_at
      return nil unless @attributes["created_at"]
      Time.parse(@attributes["created_at"])
    end
    
    def updated_at
      return nil unless @attributes["updated_at"]
      Time.parse(@attributes["updated_at"])
    end
    
    private
    def persist
      parameters = {}
      (CREATEABLE_ATTRIBUTES + ACCESSABLE_ATTRIBUTES).each do |key|
        parameters[key] = @attributes[key] if @attributes.has_key?(key)
      end
      
      new_attributes = JSON.parse(self.class.resource.post(attributes).body)
      
      (ACCESSABLE_ATTRIBUTES + READABLE_ATTRIBUTES).each do |attribute|
        @attributes[attribute] = new_attributes[attribute]
      end
      true
    end
    
    def update
      parameters = {}
      (ACCESSABLE_ATTRIBUTES).each do |key|
        parameters[key] = @attributes[key] if @attributes.has_key?(key)
      end
      
      self.class.resource[id].put(parameters)
      true
    end
  end
end
