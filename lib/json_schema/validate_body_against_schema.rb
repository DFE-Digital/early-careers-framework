# frozen_string_literal: true

require "json_schema/validation"
require "json_schema/version_event_file_name"

module JsonSchema
  class ValidateBodyAgainstSchema
    class << self
      def call(error_checker: ::JsonSchema::Validation, schema:, body:)
        new(error_checker: error_checker).call(schema: schema, body: body)
      end
    end

    def call(schema:, body:)
      @error_checker.call(schema: schema, body: body)
    end

  private

    def initialize(error_checker: ::JsonSchema::Validation)
      @error_checker = error_checker
    end
  end
end
