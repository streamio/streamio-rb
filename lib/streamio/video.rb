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
    
    # Adds a transcoding to the video instance.
    #
    # @param [Hash] parameters The parameters to pass in when creating the transcoding.
    #
    # @option parameters [String] :encoding_profile_id Id of the Encoding Profile to be used for the transcoding.
    #
    # @return [Boolean] Indicating wether the transcoding was successfully created.
    def add_transcoding(parameters)
      self.class.resource["#{id}/transcodings"].post(parameters)
      true
    rescue RestClient::Exception
      false
    end
    
    # Deletes a transcoding from the video.
    #
    # @param [String] transcoding_id The id of the transcoding to be deleted.
    #
    # @return [Boolean] Indicating wether the transcoding was successfully deleted.
    def delete_transcoding(transcoding_id)
      self.class.resource["#{id}/transcodings/#{transcoding_id}"].delete
      true
    rescue RestClient::Exception
      false
    end
  end
end
