module Streamio
  class Model
    class << self
      # Gets a model by its id.
      #
      # @param [String] id The models id.
      #
      # @return [Model] The found model.
      def find(id)
        parse_response(resource["#{id}"].get)
      end
      
      # Querys for a list of models.
      #
      # @param [Hash] parameters The parameters will determine the conditions
      # for the query. Refer to Streamio API reference for a list of valid
      # parameters for each of the different models availible.
      #
      # @return [Array] Array of found models.
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
    
    # A Hash resulting from parsing the JSON returned from Streamios API.
    attr_reader :attributes
    
    # A Hash containing validation errors after a failed +save+.
    attr_reader :errors
    
    # @param [Hash] attributes The attributes you wish to apply to the new Model instance.
    def initialize(attributes = {})
      @errors = {}
      @attributes = attributes.inject(Hash.new) do |options, (key, value)|
        options[key.to_s] = value
        options
      end
    end
    
    # Saves the model.
    #
    # If the model is new a record gets created, otherwise the existing record
    # gets updated.
    #
    # If +save+ fails it might be due to validation errors so you might want
    # to check the models +errors+.
    #
    # @return [Boolean] Indicating if the save / update was successful.
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
    
    # Deletes the record and freezes this instance to reflect that no changes
    # should be made (since they can't be persisted).
    #
    # @return [Boolean] True if the record was deleted.
    def destroy
      self.class.resource[id].delete
      @attributes.freeze
      true
    end
    
    # @return [Boolean] True if the record is persisted.
    def persisted?
      !destroyed? && !id.nil?
    end
    
    # @return [Boolean] True if you destroyed this record.
    def destroyed?
      @attributes.frozen?
    end
    
    # @return [Array] Array of tags applied to the record.
    def tags
      @attributes["tags"] = [] if @attributes["tags"].nil?
      @attributes["tags"]
    end
    
    # @return [Time] When the record was created.
    def created_at
      return nil unless @attributes["created_at"]
      Time.parse(@attributes["created_at"])
    end
    
    # @return [Time] When the record was last updated.
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
