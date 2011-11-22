module Streamio
  class Playlist < Model
    resource_name "playlists"
    accessable_attributes %w(title tags order_by order_direction)
    readable_attributes %w(id created_at updated_at account_id)  
  end
end
