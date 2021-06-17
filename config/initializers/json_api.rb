# frozen_string_literal: true

JSONAPI.configure do |config|
  # built in key format options are :underscored_key, :camelized_key and :dasherized_key
  config.json_key_format = :underscored_key

  config.resource_key_type = :uuid
end
