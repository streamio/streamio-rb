module Streamio
  class Image < Model
    resource_name "images"
    creatable_attributes %w(file)
    accessable_attributes %w(title tags)
    readable_attributes %w(id created_at updated_at account_id transcodings)  
  end
end
