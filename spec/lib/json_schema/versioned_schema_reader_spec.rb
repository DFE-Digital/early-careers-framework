# frozen_string_literal: true

require "rails_helper"
require "json_schema/versioned_schema_reader"

describe ::JsonSchema::VersionedSchemaReader do
  let(:original_schema_file) { "https://digital.education.gov.uk/schema/ecf/contracts/create/request_schema.json" }
  let(:parsed_schema_file) { ::JSON::Util::URI.normalized_uri(original_schema_file) }
  let(:current_schema_file) { Rails.root.join("etc/schema/1.0/ecf/contracts/create/request_schema.json").to_s }
  let(:versioned_schema_file) { Rails.root.join("etc/schema/0.2/ecf/contracts/create/request_schema.json").to_s }
  let(:minimal_url_file) { "https://digital.education.gov.uk/schema/ecf/contracts/create/request_schema.json" }

  it "maps uri to default path when passed an empty config" do
    mapper = described_class.new
    expect(mapper.send(:uri_to_file, parsed_schema_file.path)).to eq(current_schema_file)
  end

  it "maps uri to version path" do
    mapper = described_class.new(version: "0.2")
    expect(mapper.send(:uri_to_file, parsed_schema_file.path)).to eq(versioned_schema_file)
  end

  it "reads the disk based file when passed a mappable url" do
    mapper = described_class.new(version: "1.0")
    test_schema = mapper.read(URI(minimal_url_file))
    expect(test_schema).to be_a(JSON::Schema)
  end
end
