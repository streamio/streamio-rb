module Streamio
  class Video < Model
    resource_name "videos"
    creatable_attributes %w(file encoding_profile_ids encoding_profile_tags skip_default_encoding_profiles use_original_as_transcoding)
    accessable_attributes %w(title description tags image_id)
    readable_attributes %w(id state progress aspect_ratio_multiplier plays duration created_at updated_at account_id transcodings original_video)
    
    # Adds a transcoding to the video instance and reloads itself to
    # reflect the changed transcodings array.
    #
    # @param [Hash] parameters The parameters to pass in when creating the transcoding.
    #
    # @option parameters [String] :encoding_profile_id Id of the Encoding Profile to be used for the transcoding.
    #
    # @return [Boolean] Indicating wether the transcoding was successfully created.
    def add_transcoding(parameters)
      response = self.class.resource.post("#{id}/transcodings", parameters)
      reload
      response.code.to_i == 201
    end
    
    # Deletes a transcoding from the video and reloads itself to
    # reflect the changed transcodings array.
    #
    # @param [String] transcoding_id The id of the transcoding to be deleted.
    #
    # @return [Boolean] Indicating wether the transcoding was successfully deleted.
    def delete_transcoding(transcoding_id)
      response = self.class.resource.delete("#{id}/transcodings/#{transcoding_id}")
      reload
      response.code.to_i == 200
    end
  end
end
