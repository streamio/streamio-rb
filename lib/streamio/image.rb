module Streamio
  class Image < Model
    def self.resource
      RestClient::Resource.new("#{Streamio.authenticated_api_base}/images", :headers => {:accept => :json})
    end
    
    creatable_attributes %w(file)
    accessable_attributes %w(title tags)
    readable_attributes %w(id created_at updated_at account_id transcodings)  
  end
end
