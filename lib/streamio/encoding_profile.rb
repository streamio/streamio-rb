module Streamio
  class EncodingProfile < Model
    def self.resource
      RestClient::Resource.new("#{Streamio.authenticated_api_base}/encoding_profiles", :headers => {:accept => :json})
    end
    
    CREATEABLE_ATTRIBUTES = []
    ACCESSABLE_ATTRIBUTES = %w(title tags width desired_video_bitrate frame_rate audio_bitrate audio_sample_rate audio_channels)
    READABLE_ATTRIBUTES = %w(id created_at updated_at account_id)
    
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
