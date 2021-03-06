# frozen_string_literal: true

require "swagger_helper"

describe "API", type: :request, swagger_doc: "v1/api_spec.json", with_feature_flags: { participant_data_api: "active" } do
  let(:cpd_lead_provider) { create(:cpd_lead_provider, lead_provider: lead_provider) }
  let(:lead_provider) { create(:lead_provider) }
  let(:token) { LeadProviderApiToken.create_with_random_token!(cpd_lead_provider: cpd_lead_provider) }
  let(:bearer_token) { "Bearer #{token}" }
  let(:Authorization) { bearer_token }

  path "/api/v1/participants" do
    get "Retrieve multiple participants" do
      operationId :participants
      tags "participant"
      consumes "application/json"
      security [bearerAuth: []]

      parameter name: :filter,
                in: :query,
                schema: {
                  "$ref": "#/components/schemas/ParticipantFilter",
                },
                type: :object,
                style: :deepObject,
                explode: true,
                required: false,
                description: "Refine participants to return.",
                example: { updated_since: "2020-11-13T11:21:55Z" }

      parameter name: :page,
                in: :query,
                schema: {
                  "$ref": "#/components/schemas/Pagination",
                },
                type: :object,
                style: :deepObject,
                explode: true,
                required: false,
                example: { page: 1, per_page: 5 },
                description: "Pagination options to navigate through the collection."

      response "200", "An array of participants" do
        schema "$ref": "#/components/schemas/MultipleParticipantResponse"

        run_test!
      end

      response "401", "Unauthorized" do
        let(:Authorization) { "Bearer invalid" }

        schema "$ref": "#/components/schemas/UnauthorisedResponse"

        run_test!
      end
    end
  end

  path "/api/v1/participants.csv" do
    get "Retrieve multiple participants in CSV format" do
      operationId :participants_csv
      tags "participant"
      consumes "application/json"
      security [bearerAuth: []]

      parameter name: :filter,
                in: :query,
                schema: {
                  "$ref": "#/components/schemas/ParticipantFilter",
                },
                type: :object,
                style: :deepObject,
                explode: true,
                required: false,
                description: "Refine participants to return.",
                example: { updated_since: "2020-11-13T11:21:55Z" }

      response "200", "A CSV file of participants" do
        schema({ "$ref": "#/components/schemas/MultipleParticipantCsvResponse" }, content_type: "text/csv")

        run_test!
      end

      response "401", "Unauthorized" do
        let(:Authorization) { "Bearer invalid" }

        schema "$ref": "#/components/schemas/UnauthorisedResponse"

        run_test!
      end
    end
  end
end
