module Streamio
  class Upload < Model
    resource_name "uploads"
    accessable_attributes %w(title tags)
    readable_attributes %w(id created_at updated_at account_id)
  end
end