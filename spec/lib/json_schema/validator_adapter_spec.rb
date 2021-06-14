# frozen_string_literal: true

require "rails_helper"
require "json_schema/validator_adapter"

describe JsonSchema::ValidatorAdapter do
  context "when validating" do
    let(:body) { { "a" => 5 } }
    let(:invalid_body) { { "b" => 6 } }
    let(:extra_attributes) { { "a" => 42, "b" => 16, "extra_stuff" => "not required" } }
    let(:schema) do
      {
        "type" => "object",
        "required" => %w[a],
        "properties" => {
          "a" => { "type" => "integer", "default" => 42 },
          "b" => { "type" => "integer" },
        },
        "additionalProperties": false,
      }
    end

    it "validates a json body against a schema" do
      expect(described_class.fully_validate(schema, body, schema_reader: JSON::Schema::Reader.new)).to eq []
      expect(*described_class.fully_validate(schema, invalid_body, schema_reader: JSON::Schema::Reader.new)).to include("did not contain a required property of 'a'").once
      expect(*described_class.fully_validate(schema, extra_attributes, schema_reader: JSON::Schema::Reader.new)).to include("contains additional properties [\"extra_stuff\"] outside of the schema when none are allowed in schema").once
    end
  end
end
