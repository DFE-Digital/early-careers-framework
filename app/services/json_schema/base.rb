# frozen_string_literal: true

require "json_schema/validation"
require "json_schema/version_event_file_name"

module JsonSchema
  class Base
    include InitializeWithConfig

    def call(body:)
      config[:schema] = schema
      error_checker.call(config, body: body)
    end

  private

    def schema
      JSON.parse(File.read(json_schema_file_location.call(config)))
    end

    def default_config
      {
        version: "1.0",
        event: "create",
        error_checker: JsonSchema::Validation,
        json_schema_file_location: JsonSchema::VersionEventFileName,
      }
    end
  end
end
