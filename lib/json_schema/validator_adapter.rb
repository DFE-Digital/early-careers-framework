# frozen_string_literal: true

module JsonSchema
  class ValidatorAdapter < ::JSON::Validator
    class << self
      def fully_validate(schema, body, schema_reader: VersionedSchemaReader.new)
        super(schema, body, schema_reader: schema_reader)
      end
    end
  end
end
