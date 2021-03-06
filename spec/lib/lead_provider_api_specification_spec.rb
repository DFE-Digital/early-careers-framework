# frozen_string_literal: true

require "rails_helper"
require "lead_provider_api_specification"

RSpec.describe LeadProviderApiSpecification do
  describe ".as_yaml" do
    it "includes only the expected paths" do
      paths = %w[
        /api/v1/participant-declarations
        /api/v1/participants
        /api/v1/participants.csv
      ]

      expect(LeadProviderApiSpecification.as_hash["paths"].keys).to eq(paths)
    end
  end
end
