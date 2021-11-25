# frozen_string_literal: true

require "json_schema/validation"

class SchemaValidator
  CACHED_SCHEMAS = JSON.parse(File.read(Rails.root.join("swagger/v1/api_spec.json")))["components"]["schemas"]

  attr_accessor :raw_event

  class << self
    def call(raw_event:)
      new(raw_event: raw_event).call
    end
  end

  def call
    validate_schema!
  end

private

  def initialize(raw_event:)
    @raw_event = raw_event
  end

  def schema
    # TODO: need to pull in correct schema depending on request
    hash = YAML.safe_load(File.read(Rails.root.join("swagger/v1/component_schemas/ParticipantDeclarationRequest.yml")))

    hash["components"] = {}
    hash["components"]["schemas"] = {}
    hash["components"]["schemas"] = CACHED_SCHEMAS

    hash
  end

  def validate_schema!
    JSON::Validator.fully_validate(schema, raw_event)
  end
end
