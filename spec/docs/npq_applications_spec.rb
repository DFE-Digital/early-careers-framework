# frozen_string_literal: true

require "swagger_helper"

describe "API", type: :request, swagger_doc: "v1/api_spec.json" do
  let(:cpd_lead_provider) { create(:cpd_lead_provider, npq_lead_provider: npq_lead_provider) }
  let(:npq_lead_provider) { create(:npq_lead_provider) }
  let(:token) { LeadProviderApiToken.create_with_random_token!(cpd_lead_provider: cpd_lead_provider) }
  let(:Authorization) { "Bearer #{token}" }

  path "/api/v1/npq-applications" do
    get "Retrieve multiple NPQ applications" do
      operationId :npq_applications
      tags "NPQ applications"
      security [bearerAuth: []]

      parameter name: :filter,
                in: :query,
                schema: {
                  "$ref": "#/components/schemas/ListFilter",
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
                  "$ref": "#/components/schemas/Pagination",
                },
                type: :object,
                style: :deepObject,
                explode: true,
                required: false,
                example: { page: 1, per_page: 5 },
                description: "Pagination options to navigate through the list of NPQ applications."

      response "200", "An list of NPQ applications" do
        schema({ "$ref": "#/components/schemas/MultipleNpqApplicationsResponse" }, content_type: "application/vnd.api+json")

        run_test!
      end

      response "401", "Unauthorized" do
        let(:Authorization) { "Bearer invalid" }
        run_test!
      end
    end
  end

  path "/api/v1/npq-applications.csv" do
    get "Retrieve all NPQ applications in CSV format" do
      operationId :npq_applications_csv
      tags "NPQ applications"
      security [bearerAuth: []]

      parameter name: :filter,
                in: :query,
                schema: {
                  "$ref": "#/components/schemas/ListFilter",
                },
                type: :object,
                style: :deepObject,
                explode: true,
                required: false,
                description: "Refine NPQ applications to return.",
                example: { updated_since: "2020-11-13T11:21:55Z" }

      response "200", "A CSV file of NPQ application" do
        schema({ "$ref": "#/components/schemas/MultipleNpqApplicationsCsvResponse" }, content_type: "text/csv")

        run_test!
      end

      response "401", "Unauthorized" do
        let(:Authorization) { "Bearer invalid" }

        schema({ "$ref": "#/components/schemas/UnauthorisedResponse" }, content_type: "application/vnd.api+json")

        run_test!
      end
    end
  end
end
