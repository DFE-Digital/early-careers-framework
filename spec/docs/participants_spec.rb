# frozen_string_literal: true

require "swagger_helper"

describe "API", type: :request, swagger_doc: "v1/api_spec.json", with_feature_flags: { participant_data_api: "active" } do
  let(:token) { LeadProviderApiToken.create_with_random_token!(lead_provider: create(:lead_provider)) }
  let(:bearer_token) { "Bearer #{token}" }
  let(:Authorization) { bearer_token }

  path "/api/v1/participants" do
    get "Retrieve multiple participants" do
      operationId :api_v1_participants
      tags "participant"
      produces "application/vnd.api+json"
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
                  type: :object,
                  description: "This schema used to paginate through a collection.",
                  properties: {
                    page: {
                      type: :integer,
                      description: "The page number to paginate to in the collection. If no value is specified it defaults to the first page.",
                      example: 3,
                    },
                    per_page: {
                      type: :integer,
                      description: "The number items to display on a page. Defaults to 100. Maximum is 500, if the value is greater that the maximum allowed it will fallback to 500.",
                      example: 10,
                    },
                  },
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

        schema "$ref": "#/components/schemas/UnauthorizedResponse"

        run_test!
      end
    end
  end

  path "/api/v1/participants.csv" do
    get "Retrieve multiple participants in CSV format" do
      operationId :api_v1_participants_csv
      tags "participant"
      produces "text/csv"
      security [bearerAuth: []]

      parameter name: :filter,
                in: :query,
                schema: {
                  type: :object,
                  example: "",
                  description: "This schema is used to search within collections to return more specific results.",
                  properties: {
                    updated_since: {
                      description: "Return participants that have been updated since the date (ISO 8601 date format)",
                      type: :string,
                      example: "2021-05-13T11:21:55Z",
                    },
                  },
                },
                type: :object,
                style: :deepObject,
                explode: true,
                required: false,
                description: "Refine participants to return.",
                example: { updated_since: "2020-11-13T11:21:55Z" }

      response "200", "A CSV file of participants" do
        schema "$ref": "#/components/schemas/MultipleParticipantCsvResponse"

        run_test!
      end

      response "401", "Unauthorized" do
        let(:Authorization) { "Bearer invalid" }

        schema "$ref": "#/components/schemas/UnauthorizedResponse"

        run_test!
      end
    end
  end
end
