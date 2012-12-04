module Streamio
  class Audio < Model
    resource_name "audios"
    creatable_attributes %w(file)
    accessable_attributes %w(title description tags)
    readable_attributes %w(id state progress plays duration created_at updated_at account_id transcodings original_file)
  end
end
