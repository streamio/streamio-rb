module Streamio
  class EncodingProfile < Model
    resource_name "encoding_profiles"
    accessable_attributes %w(title tags width desired_video_bitrate frame_rate audio_bitrate audio_sample_rate audio_channels)
    readable_attributes %w(id created_at updated_at account_id)
  end
end
