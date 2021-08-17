# frozen_string_literal: true

require "swagger_helper"

describe "API", type: :request, swagger_doc: "v1/api_spec.json" do
  let!(:default_schedule) { create(:schedule, name: "ECF September standard 2021") }
  let(:cpd_lead_provider) { create(:cpd_lead_provider, npq_lead_provider: npq_lead_provider) }
  let(:npq_lead_provider) { create(:npq_lead_provider) }
  let(:token) { LeadProviderApiToken.create_with_random_token!(cpd_lead_provider: cpd_lead_provider) }
  let(:Authorization) { "Bearer #{token}" }
  let(:npq_application) { create(:npq_validation_data, npq_lead_provider: npq_lead_provider) }

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

      response "200", "A list of NPQ applications" do
        before do
          npq_application
        end

        schema({ "$ref": "#/components/schemas/MultipleNpqApplicationsResponse" }, content_type: "application/vnd.api+json")

        run_test!
      end

      response "401", "Unauthorized" do
        let(:Authorization) { "Bearer invalid" }

        schema({ "$ref": "#/components/schemas/UnauthorisedResponse" }, content_type: "application/vnd.api+json")

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

  path "/api/v1/npq-applications/{id}/accept" do
    post "Accept an NPQ application" do
      operationId :npq_applications_accept
      tags "NPQ applications"
      security [bearerAuth: []]

      parameter name: :id,
                in: :path,
                type: :string,
                required: true,
                example: SecureRandom.uuid,
                description: "The ID of the NPQ application to accept."

      response "200", "The NPQ application being accepted" do
        let(:id) { npq_application.id }

        schema({ "$ref": "#/components/schemas/NpqApplicationResponse" }, content_type: "application/vnd.api+json")

        run_test!
      end

      response "401", "Unauthorized" do
        let(:Authorization) { "Bearer invalid" }
        let(:id) { npq_application.id }

        schema({ "$ref": "#/components/schemas/UnauthorisedResponse" }, content_type: "application/vnd.api+json")

        run_test!
      end
    end
  end

  path "/api/v1/npq-applications/{id}/reject" do
    post "Reject an NPQ application" do
      operationId :npq_applications_reject
      tags "NPQ applications"
      security [bearerAuth: []]

      parameter name: :id,
                in: :path,
                type: :string,
                required: true,
                example: SecureRandom.uuid,
                description: "The ID of the NPQ application to reject."

      response "200", "The NPQ application being rejected" do
        let(:id) { npq_application.id }

        schema({ "$ref": "#/components/schemas/NpqApplicationResponse" }, content_type: "application/vnd.api+json")

        run_test!
      end

      response "401", "Unauthorized" do
        let(:Authorization) { "Bearer invalid" }
        let(:id) { npq_application.id }

        schema({ "$ref": "#/components/schemas/UnauthorisedResponse" }, content_type: "application/vnd.api+json")

        run_test!
      end
    end
  end
end
