# frozen_string_literal: true

require "swagger_helper"

describe "API", :with_default_schedules, type: :request, swagger_doc: "v3/api_spec.json" do
  let(:cpd_lead_provider) { create(:cpd_lead_provider, npq_lead_provider:) }
  let(:npq_lead_provider) { create(:npq_lead_provider) }
  let(:token) { LeadProviderApiToken.create_with_random_token!(cpd_lead_provider:) }
  let(:Authorization) { "Bearer #{token}" }
  let(:npq_course) { create(:npq_course, identifier: "npq-senior-leadership") }
  let(:npq_application) { create(:npq_application, npq_lead_provider:, npq_course:) }

  path "/api/v3/npq-applications" do
    get "Retrieve multiple NPQ applications" do
      operationId :npq_applications
      tags "NPQ applications"
      security [bearerAuth: []]

      parameter name: :filter,
                in: :query,
                schema: {
                  "$ref": "#/components/schemas/NPQApplicationsFilter",
                },
                type: :object,
                style: :deepObject,
                explode: true,
                required: false,
                description: "Refine NPQ applications to return.",
                example: CGI.unescape({
                  filter: {
                    cohort: "2021,2022",
                    updated_since: "2020-11-13T11:21:55Z",
                    participant_id: "7e5bcdbf-c818-4961-8da5-439cab1984e0,c2a7ef98-bbfc-48c5-8f02-d484071d2165",
                  },
                }.to_param)

      parameter name: :page,
                in: :query,
                schema: {
                  "$ref": "#/components/schemas/Pagination",
                },
                type: :object,
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

  path "/api/v3/npq-applications/{id}/accept" do
    post "Accept an NPQ application" do
      operationId :npq_applications_accept
      tags "NPQ applications"
      security [bearerAuth: []]

      parameter name: :id,
                in: :path,
                type: :string,
                required: true,
                example: "28c461ee-ffc0-4e56-96bd-788579a0ed75",
                description: "The ID of the NPQ application to accept."

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

  path "/api/v3/npq-applications/{id}/reject" do
    post "Reject an NPQ application" do
      operationId :npq_applications_reject
      tags "NPQ applications"
      security [bearerAuth: []]

      parameter name: :id,
                in: :path,
                type: :string,
                required: true,
                example: "14b1b4ab-fa81-4f7a-b4b5-f632412e8c5c",
                description: "The ID of the NPQ application to reject."

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
end
