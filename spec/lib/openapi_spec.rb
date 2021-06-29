# frozen_string_literal: true

require "rails_helper"
require "lead_provider_api_specification"

RSpec.describe "OpenAPI spec" do
  document = Openapi3Parser.load(LeadProviderApiSpecification.as_hash)

  it "is a valid OpenAPI spec" do
    expect(document).to be_valid, document.errors.to_a.inspect
  end

  document.components.schemas.each do |schema_name, schema|
    describe schema_name do
      it "requires all of the keys to be present" do
        required_properties = schema.required.to_a
        actual_properties = schema.properties.map { |property_name, _| property_name }

        expect(actual_properties).to include(*required_properties)
      end

      schema.properties.each do |property_name, property|
        next unless property.type.in?(%w[string boolean])

        it "requires description for #{schema_name}.#{property_name}" do
          expect(property.description).not_to be_nil
        end

        it "requires example for #{schema_name}.#{property_name}" do
          expect(property.example).not_to be_nil unless property.deprecated? && property.nullable?
        end
      end
    end
  end
end
