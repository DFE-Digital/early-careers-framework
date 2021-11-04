# frozen_string_literal: true

require "rails_helper"
require "lead_provider_api_specification"

RSpec.describe LeadProviderApiSpecification do
  describe ".as_yaml" do
    it "includes only the expected paths" do
      paths = %w[
        /api/v1/npq-applications
        /api/v1/npq-applications.csv
        /api/v1/npq-applications/{id}/accept
        /api/v1/npq-applications/{id}/reject
        /api/v1/participants/npq
        /api/v1/participants/npq/{id}/defer
        /api/v1/participants/npq/{id}/withdraw
        /api/v1/participants/npq/{id}/resume
        /api/v1/participant-declarations
        /api/v1/participant-declarations.csv
        /api/v1/participant-declarations/{id}
        /api/v1/participant-declarations/{id}/void
        /api/v1/participants/ecf
        /api/v1/participants/ecf.csv
        /api/v1/participants/ecf/{id}/defer
        /api/v1/participants/ecf/{id}/withdraw
        /api/v1/participants/ecf/{id}/resume
        /api/v1/participants/{id}/defer
        /api/v1/participants/{id}/resume
        /api/v1/participants/{id}/change-schedule
        /api/v1/participants/{id}/withdraw
      ]

      expect(LeadProviderApiSpecification.as_hash["paths"].keys).to match_array(paths)
    end
  end
end
