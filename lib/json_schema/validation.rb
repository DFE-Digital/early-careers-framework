# frozen_string_literal: true

require "json_schema/version_event_file_name"
require "json_schema/versioned_schema_reader"
require "json_schema/validator_adapter"

module JsonSchema
  class Validation
    class << self
      def call(schema:, body:, version: "1.0", schema_reader: ::JsonSchema::VersionedSchemaReader, schema_validator: ::JsonSchema::ValidatorAdapter)
        new(schema_reader: schema_reader, schema_validator: schema_validator, version: version).call(schema: schema, body: body)
      end
    end

    def call(schema:, body:)
      @schema_validator.fully_validate(schema, body, schema_reader: @schema_reader.new(version: @version))
    end

  private

    def initialize(version: "1.0", schema_reader: ::JsonSchema::VersionedSchemaReader, schema_validator: ::JsonSchema::ValidatorAdapter)
      @schema_validator = schema_validator
      @schema_reader = schema_reader
      @version = version
    end
  end
end
