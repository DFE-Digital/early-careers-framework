# frozen_string_literal: true

require "rails_helper"
require "lead_provider_api_specification"

RSpec.describe LeadProviderApiSpecification do
  describe ".as_yaml" do
    context "with a version specified" do
      it "includes only the expected paths for the version" do
        paths = %w[
          /api/v1/npq-applications
          /api/v1/npq-applications.csv
          /api/v1/npq-applications/{id}
          /api/v1/npq-applications/{id}/accept
          /api/v1/npq-applications/{id}/reject
          /api/v1/npq-applications/{id}/change-funded-place
          /api/v1/participants/npq
          /api/v1/participants/npq/{id}
          /api/v1/participants/npq/{id}/defer
          /api/v1/participants/npq/{id}/withdraw
          /api/v1/participants/npq/{id}/resume
          /api/v1/participant-declarations
          /api/v1/participant-declarations.csv
          /api/v1/participant-declarations/{id}
          /api/v1/participant-declarations/{id}/void
          /api/v1/participants/ecf
          /api/v1/participants/ecf/{id}
          /api/v1/participants/ecf.csv
          /api/v1/participants/ecf/{id}/defer
          /api/v1/participants/ecf/{id}/withdraw
          /api/v1/participants/ecf/{id}/resume
          /api/v1/participants/{id}/defer
          /api/v1/participants/{id}/resume
          /api/v1/participants/{id}/change-schedule
          /api/v1/participants/ecf/{id}/change-schedule
          /api/v1/participants/npq/{id}/change-schedule
          /api/v1/participants/npq/outcomes
          /api/v1/participants/npq/{participant_id}/outcomes
          /api/v1/participants/{id}/withdraw
        ]

        expect(LeadProviderApiSpecification.as_hash("v1")["paths"].keys).to contain_exactly(*paths)
      end
    end

    it "calls the preprocessor" do
      preprocessor = instance_double(LeadProviderApiSpecification::Preprocessor, preprocess!: nil)
      expect(LeadProviderApiSpecification::Preprocessor).to receive(:new).with("swagger/v1/api_spec.json").and_return(preprocessor)

      LeadProviderApiSpecification.as_hash("v1")

      expect(preprocessor).to have_received(:preprocess!)
    end
  end
end
