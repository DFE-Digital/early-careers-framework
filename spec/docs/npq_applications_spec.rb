# frozen_string_literal: true

require "swagger_helper"

describe "API", type: :request, swagger_doc: "v1/api_spec.json" do
  let(:cpd_lead_provider) { create(:cpd_lead_provider, npq_lead_provider: npq_lead_provider) }
  let(:npq_lead_provider) { create(:npq_lead_provider) }
  let(:token) { LeadProviderApiToken.create_with_random_token!(cpd_lead_provider: cpd_lead_provider) }
  let(:Authorization) { "Bearer #{token}" }

  path "/api/v1/npq-applications" do
    get "Returns all NPQ applications for current lead provider" do
      operationId :api_v1_npq_applications_index
      tags "npq_applications"
      produces "application/vnd.api+json"
      security [bearerAuth: []]

      parameter name: :filter,
                in: :query,
                schema: {
                  type: :object,
                  description: "This schema is used to search within collections to return more specific results.",
                  example: { updated_since: "2020-11-13T11:21:55Z" },
                  properties: {
                    updated_since: {
                      description: "Return participants that have been updated since the specified timestamp (ISO 8601 format)",
                      type: :string,
                      example: "2021-05-13T11:21:55Z",
                    },
                  },
                },
                type: :object,
                style: :deepObject,
                explode: true,
                required: false,
                description: "Refine NPQ applications to return.",
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
                      description: "The number items to display on a page. Defaults to 100. Maximum is 500, if the value is greater that the maximum allowed it will fallback to 100.",
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

      response "200", "Collection of NPQ applications." do
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
                         required: %w[
                           id
                           participant_id
                           full_name
                           email
                           email_validated
                           teacher_reference_number
                           teacher_reference_number_validated
                           school_urn
                           headteacher_status
                           eligible_for_funding
                           funding_choice
                           course_identifier
                         ],
                         properties: {
                           id: { type: :string },
                           participant_id: { type: :string },
                           full_name: { type: :string },
                           email: { type: :string },
                           email_validated: { type: :boolean },
                           teacher_reference_number: { type: :string },
                           teacher_reference_number_validated: { type: :boolean },
                           school_urn: { type: :string },
                           headteacher_status: {
                             type: :string,
                             enum: %w[no yes_when_course_starts yes_in_first_two_years yes_over_two_years],
                           },
                           eligible_for_funding: { type: :boolean },
                           funding_choice: {
                             type: :string,
                             enum: %w[school trust self another],
                           },
                           course_identifier: { type: :string },
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

  path "/api/v1/npq-applications.csv" do
    get "Returns all NPQ applications for the current lead provider" do
      operationId :api_v1_npq_applications_index_csv
      tags "npq_applications"
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
                      description: "Return participants that have been updated since the specified timestamp (ISO 8601 format)",
                      type: :string,
                      example: "2021-05-13T11:21:55Z",
                    },
                  },
                },
                type: :object,
                style: :deepObject,
                explode: true,
                required: false,
                description: "Refine NPQ applications to return.",
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
