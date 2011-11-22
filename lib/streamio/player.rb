module Streamio
  class Player < Model
    resource_name "players"
    creatable_attributes []
    accessable_attributes %w(title tags width height skin loop autoplay enable_rtmp show_title show_play_pause_button show_elapsed_time show_seek_bar show_total_time show_volume_control show_full_screen_button google_analytics_property_id smartclip_preroll_url smartclip_html5_preroll_url playlist limit css)
    readable_attributes %w(id created_at updated_at account_id playlist_ids)
  end
end
