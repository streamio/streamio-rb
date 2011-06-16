module Streamio
  class Model
    class << self
      def find(id)
        parse_response(resource["#{id}"].get)
      end
      
      def all(parameters = {})
        sanitize_parameters(parameters)
        parse_response(resource.get(:params => parameters))
      end
      
      protected
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
    
    CASTED_ATTRIBUTES = %w(tags created_at updated_at)
  
    attr_reader :attributes, :errors
  
    def initialize(attributes = {})
      @errors = {}
      @attributes = attributes.inject(Hash.new) do |options, (key, value)|
        options[key.to_s] = value
        options
      end
    end
  
    # Saves the model.
    #
    # If the model is new a record gets created in the database, otherwise
    # the existing record gets updated.
    #
    # If +save+ fails it might be due to validation errors so you might want
    # to check the model for +errors+ if +save+ returned +false+.
    #
    # @return [ Boolean ] Boolean indicating if the save / update was successful.
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
  
    def persisted?
      !destroyed? && !id.nil?
    end
  
    def destroyed?
      @attributes.frozen?
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
    def update
      parameters = {}
      (self.class::ACCESSABLE_ATTRIBUTES).each do |key|
        parameters[key] = @attributes[key] if @attributes.has_key?(key)
      end

      self.class.resource[id].put(parameters)
      true
    end
    
    def persist
      parameters = {}
      (self.class::CREATEABLE_ATTRIBUTES + self.class::ACCESSABLE_ATTRIBUTES).each do |key|
        parameters[key] = @attributes[key] if @attributes.has_key?(key)
      end

      new_attributes = JSON.parse(self.class.resource.post(attributes).body)

      (self.class::ACCESSABLE_ATTRIBUTES + self.class::READABLE_ATTRIBUTES).each do |attribute|
        @attributes[attribute] = new_attributes[attribute]
      end
      true
    end
  end
end
