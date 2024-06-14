# frozen_string_literal: true

require "swagger_helper"

describe "API", type: :request, swagger_doc: "v1/api_spec.json" do
  let(:cpd_lead_provider) { create(:cpd_lead_provider, npq_lead_provider:) }
  let(:npq_lead_provider) { create(:npq_lead_provider) }
  let(:token) { LeadProviderApiToken.create_with_random_token!(cpd_lead_provider:) }
  let(:Authorization) { "Bearer #{token}" }
  let(:npq_course) { create(:npq_course, identifier: "npq-senior-leadership") }
  let(:npq_application) { create(:npq_application, npq_lead_provider:, npq_course:) }

  path "/api/v1/npq-applications" do
    get "Retrieve multiple NPQ applications" do
      operationId :npq_applications
      tags "NPQ applications"
      produces "application/json"
      security [bearerAuth: []]

      parameter name: :filter,
                in: :query,
                schema: {
                  "$ref": "#/components/schemas/ListFilter",
                },
                style: :deepObject,
                explode: true,
                required: false,
                description: "Refine NPQ applications to return.",
                example: CGI.unescape({ filter: { cohort: 2022, updated_since: "2020-11-13T11:21:55Z" } }.to_param)

      parameter name: :page,
                in: :query,
                schema: {
                  "$ref": "#/components/schemas/Pagination",
                },
                style: :deepObject,
                explode: true,
                required: false,
                example: CGI.unescape({ page: { page: 1, per_page: 5 } }.to_param),
                description: "Pagination options to navigate through the list of NPQ applications."

      response "200", "A list of NPQ applications" do
        schema({ "$ref": "#/components/schemas/MultipleNPQApplicationsResponse" })

        run_test!
      end

      response "401", "Unauthorized" do
        let(:Authorization) { "Bearer invalid" }

        schema({ "$ref": "#/components/schemas/UnauthorisedResponse" })

        run_test!
      end
    end
  end

  path "/api/v1/npq-applications.csv" do
    get "Retrieve all NPQ applications in CSV format" do
      operationId :npq_applications_csv
      tags "NPQ applications"
      produces "text/csv"
      security [bearerAuth: []]

      parameter name: :filter,
                in: :query,
                schema: {
                  "$ref": "#/components/schemas/ListFilter",
                },
                style: :deepObject,
                explode: true,
                required: false,
                description: "Refine NPQ applications to return.",
                example: CGI.unescape({ updated_since: "2020-11-13T11:21:55Z" }.to_param)

      response "200", "A CSV file of NPQ application" do
        schema "$ref": "#/components/schemas/MultipleNPQApplicationsCsvResponse"

        run_test!
      end

      response "401", "Unauthorized" do
        let(:Authorization) { "Bearer invalid" }

        schema({ "$ref": "#/components/schemas/UnauthorisedResponse" })

        run_test!
      end
    end
  end

  path "/api/v1/npq-applications/{id}" do
    get "Get a single NPQ application" do
      operationId :npq_application
      tags "NPQ applications"
      produces "application/json"
      security [bearerAuth: []]

      parameter name: :id,
                in: :path,
                required: true,
                example: "28c461ee-ffc0-4e56-96bd-788579a0ed75",
                description: "The ID of the NPQ application.",
                schema: {
                  type: "string",
                }

      response "200", "A single NPQ application" do
        let(:id) { npq_application.id }

        schema({ "$ref": "#/components/schemas/NPQApplicationResponse" })

        run_test!
      end

      response "401", "Unauthorized" do
        let(:id) { npq_application.id }
        let(:Authorization) { "Bearer invalid" }

        schema({ "$ref": "#/components/schemas/UnauthorisedResponse" })

        run_test!
      end
    end
  end

  path "/api/v1/npq-applications/{id}/accept" do
    post "Accept an NPQ application" do
      operationId :npq_applications_accept
      tags "NPQ applications"
      consumes "application/json"
      produces "application/json"
      security [bearerAuth: []]

      parameter name: :id,
                in: :path,
                required: true,
                example: "28c461ee-ffc0-4e56-96bd-788579a0ed75",
                description: "The ID of the NPQ application to accept.",
                schema: {
                  type: "string",
                }

      parameter name: :params,
                in: :body,
                style: :deepObject,
                required: false,
                schema: {
                  "$ref": "#/components/schemas/NPQApplicationAcceptRequest",
                }

      response "200", "The NPQ application being accepted" do
        let(:id) { npq_application.id }

        schema({ "$ref": "#/components/schemas/NPQApplicationResponse" })

        run_test!
      end

      response "401", "Unauthorized" do
        let(:Authorization) { "Bearer invalid" }
        let(:id) { npq_application.id }

        schema({ "$ref": "#/components/schemas/UnauthorisedResponse" })

        run_test!
      end
    end
  end

  path "/api/v1/npq-applications/{id}/reject" do
    post "Reject an NPQ application" do
      operationId :npq_applications_reject
      tags "NPQ applications"
      consumes "application/json"
      produces "application/json"
      security [bearerAuth: []]

      parameter name: :id,
                in: :path,
                required: true,
                example: "14b1b4ab-fa81-4f7a-b4b5-f632412e8c5c",
                description: "The ID of the NPQ application to reject.",
                schema: {
                  type: "string",
                }

      response "200", "The NPQ application being rejected" do
        let(:id) { npq_application.id }

        schema({ "$ref": "#/components/schemas/NPQApplicationResponse" })

        run_test!
      end

      response "401", "Unauthorized" do
        let(:Authorization) { "Bearer invalid" }
        let(:id) { npq_application.id }

        schema({ "$ref": "#/components/schemas/UnauthorisedResponse" })

        run_test!
      end
    end
  end

  path "/api/v1/npq-applications/{id}/change-funded-place" do
    let(:npq_lead_provider) { create(:npq_lead_provider) }
    let(:cpd_lead_provider) { npq_lead_provider.cpd_lead_provider }
    let(:npq_course) { create(:npq_leadership_course, identifier: "npq-senior-leadership") }
    let(:funding_cap) { 10 }
    let!(:statement) do
      create(
        :npq_statement,
        :next_output_fee,
        cpd_lead_provider: npq_lead_provider.cpd_lead_provider,
        cohort: npq_application.cohort,
      )
    end
    let!(:npq_contract) do
      create(
        :npq_contract,
        npq_lead_provider:,
        cohort: statement.cohort,
        course_identifier: npq_course.identifier,
        version: statement.contract_version,
        funding_cap:,
      )
    end

    let(:npq_application) { create(:npq_application, :accepted, npq_lead_provider:, npq_course:, eligible_for_funding: true) }

    before do
      FeatureFlag.activate(:npq_capping)
    end

    put "Change funded place" do
      operationId :npq_applications_change_funded_place
      tags "NPQ applications"
      consumes "application/json"
      produces "application/json"
      security [bearerAuth: []]

      parameter name: :id,
                in: :path,
                required: true,
                example: "28c461ee-ffc0-4e56-96bd-788579a0ed75",
                description: "The ID of the NPQ participant to change funded place.",
                schema: {
                  type: :string,
                  format: :uuid,
                }

      parameter name: :params,
                in: :body,
                style: :deepObject,
                required: false,
                schema: {
                  "$ref": "#/components/schemas/ChangeFundedPlaceRequest",
                }

      response "200", "The NPQ application being accepted" do
        let(:id) { npq_application.id }

        let(:params) do
          {
            "data": {
              "type": "participant",
              "attributes": {
                funded_place: true,
              },
            },
          }
        end

        schema({ "$ref": "#/components/schemas/NPQApplicationResponse" })

        run_test!
      end

      response "401", "Unauthorized" do
        let(:Authorization) { "Bearer invalid" }
        let(:id) { npq_application.id }

        schema({ "$ref": "#/components/schemas/UnauthorisedResponse" })

        run_test!
      end

      response "404", "Not Found", exceptions_app: true do
        let(:id) { "test" }

        schema({ "$ref": "#/components/schemas/NotFoundResponse" })

        run_test!
      end
    end
  end
end
