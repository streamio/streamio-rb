module Streamio
  class EncodingProfile < Model
    def self.resource
      RestClient::Resource.new("#{Streamio.authenticated_api_base}/encoding_profiles", :headers => {:accept => :json})
    end
    
    accessable_attributes %w(title tags width desired_video_bitrate frame_rate audio_bitrate audio_sample_rate audio_channels)
    readable_attributes %w(id created_at updated_at account_id)
  end
end
