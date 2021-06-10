# frozen_string_literal: true

require "json_schema/version_event_file_name"
require "json_schema/versioned_schema_reader"
require "json_schema/validator_adapter"
require "initialize_with_config"

module JsonSchema
  class Validation
    include InitializeWithConfig
    required_config :schema, :schema_reader, :schema_validator, :version

    def call(body:)
      schema_validator.fully_validate(schema, body, schema_reader: schema_reader.new(version: version))
    end

  private

    def default_config
      {
        version: "1.0",
        schema_reader: ::JsonSchema::VersionedSchemaReader,
        schema_validator: ::JsonSchema::ValidatorAdapter,
      }
    end
  end
end
