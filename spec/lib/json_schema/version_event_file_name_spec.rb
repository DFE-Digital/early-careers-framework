# frozen_string_literal: true

require "rails_helper"
require "json_schema/version_event_file_name"

describe JsonSchema::VersionEventFileName do
  context "passed in a version and json event type" do
    let(:previous_version) { 0.1 }
    let(:current) { 0.2 }
    let(:event) { :create }

    it "requires both version and event to be specified in the config hash" do
      expect { described_class.call }.to raise_error(ArgumentError)
      expect { described_class.call({}) }.to raise_error(::InitializeWithConfig::MissingRequiredArguments, "missing required dependency injected items [:version, :event] in class JsonSchema::VersionEventFileName")
      expect { described_class.call(version: current) }.to raise_error(::InitializeWithConfig::MissingRequiredArguments, "missing required dependency injected items [:event] in class JsonSchema::VersionEventFileName")
      expect { described_class.call(event: event) }.to raise_error(::InitializeWithConfig::MissingRequiredArguments, "missing required  dependency injected items [:version] in class JsonSchema::VersionEventFileName")
    end

    it "maps to the participant_declarations schema for the required version" do
      expect(described_class.call(version: current, event: event)).to eq Rails.root.join("etc/schema/0.2/ecf/participant_declarations/create/request_schema.json")
      expect(described_class.call(version: previous_version, event: event)).to eq Rails.root.join("etc/schema/0.1/ecf/participant_declarations/create/request_schema.json")
    end

    it "allows an override to schema_path path fragment" do
      expect(described_class.call(schema_path: "ecf/contracts", version: previous_version, event: event)).to eq Rails.root.join("etc/schema/0.1/ecf/contracts/create/request_schema.json")
    end

    it "allows an override to schema_root path fragment" do
      expect(described_class.call(schema_root: "config/schemas", version: previous_version, event: event)).to eq Rails.root.join("config/schemas/0.1/ecf/participant_declarations/create/request_schema.json")
    end

    it "allows an override to the schema_file name" do
      expect(described_class.call(schema_file: "response_schema.json", version: previous_version, event: event)).to eq Rails.root.join("etc/schema/0.1/ecf/participant_declarations/create/response_schema.json")
    end
  end
end
