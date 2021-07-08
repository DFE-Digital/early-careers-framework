# frozen_string_literal: true

require "swagger_helper"

describe "API", type: :request, swagger_doc: "v1/api_spec.json", with_feature_flags: { participant_data_api: "active" } do
  let(:cpd_lead_provider) { create(:cpd_lead_provider, lead_provider: lead_provider) }
  let(:lead_provider) { create(:lead_provider) }
  let(:token) { LeadProviderApiToken.create_with_random_token!(cpd_lead_provider: cpd_lead_provider) }
  let(:bearer_token) { "Bearer #{token}" }
  let(:Authorization) { bearer_token }

  path "/api/v1/participants" do
    get "Returns all participants" do
      operationId :api_v1_participants_index
      tags "participant"
      produces "application/vnd.api+json"
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

      response "200", "Collection of participants." do
        schema type: :object,
               required: %w[data],
               properties: {
                 data: {
                   type: :array,
                   items: {
                     type: :object,
                     required: %w[id type attributes],
                     properties: {
                       id: { type: :string },
                       type: { type: :string },
                       attributes: {
                         type: :object,
                         required: %w[email full_name mentor_id school_urn participant_type cohort],
                         properties: {
                           email: { type: :string },
                           full_name: { type: :string },
                           mentor_id: { type: :string },
                           school_urn: { type: :string },
                           participant_type: {
                             type: :string,
                             enum: %w[mentor ect],
                           },
                           cohort: { type: :string },
                         },
                       },
                     },
                   },
                 },
               }

        run_test!
      end

      response "401", "Unauthorized" do
        let(:Authorization) { "Bearer invalid" }
        run_test!
      end
    end
  end

  path "/api/v1/participants.csv" do
    get "Returns all participants" do
      operationId :api_v1_participants_index
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

      response "200", "Collection of participants." do
        schema type: :string
        run_test!
      end

      response "401", "Unauthorized" do
        let(:Authorization) { "Bearer invalid" }
        run_test!
      end
    end
  end
end
