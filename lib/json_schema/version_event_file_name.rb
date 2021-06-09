# frozen_string_literal: true

require "initialize_with_config"

module JsonSchema
  class VersionEventFileName
    include InitializeWithConfig
    required_config :version, :event

    def call
      Rails.root.join(schema_root, version.to_s, schema_path, event.to_s, schema_file)
    end

  private

    def default_config
      {
        schema_root: "etc/schema",
        schema_path: "ecf/participant_declarations",
        schema_file: "request_schema.json",
      }
    end
  end
end
