module Streamio
  class Image < Model
    def self.resource
      RestClient::Resource.new("#{Streamio.authenticated_api_base}/images", :headers => {:accept => :json})
    end
    
    CREATEABLE_ATTRIBUTES = %w(file)
    ACCESSABLE_ATTRIBUTES = %w(title tags)
    READABLE_ATTRIBUTES = %w(id created_at updated_at account_id transcodings)
    
    (CREATEABLE_ATTRIBUTES + ACCESSABLE_ATTRIBUTES + READABLE_ATTRIBUTES - CASTED_ATTRIBUTES).each do |attribute|
      define_method(attribute) do
        @attributes[attribute]
      end
    end
    
    (CREATEABLE_ATTRIBUTES + ACCESSABLE_ATTRIBUTES).each do |attribute|
      define_method("#{attribute}=") do |value|
        @attributes[attribute] = value
      end
    end    
  end
end
