module Streamio
  class Video < Model
    def self.resource
      RestClient::Resource.new("#{Streamio.authenticated_api_base}/videos", :headers => {:accept => :json})
    end

    CREATEABLE_ATTRIBUTES = %w(file encoding_profile_ids encoding_profile_tags skip_default_encoding_profiles use_original_as_transcoding)
    ACCESSABLE_ATTRIBUTES = %w(title description tags image_id)
    READABLE_ATTRIBUTES = %w(id state progress aspect_ratio_multiplier plays duration created_at updated_at account_id transcodings)
    
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
    
    def add_transcoding(parameters = {})
      self.class.resource["#{id}/transcodings"].post(parameters)
      true
    rescue RestClient::Exception
      false
    end
    
    def delete_transcoding(transcoding_id)
      self.class.resource["#{id}/transcodings/#{transcoding_id}"].delete
      true
    rescue RestClient::Exception
      false
    end
  end
end
