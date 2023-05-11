# frozen_string_literal: true

require "swagger_helper"

RSpec.describe "API", :with_default_schedules, type: :request, swagger_doc: "v3/api_spec.json", with_feature_flags: { api_v3: "active" } do
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
                style: :deepObject,
                explode: true,
                required: false,
                example: CGI.unescape({ page: { page: 1, per_page: 5 } }.to_param),
                description: "Pagination options to navigate through the list of NPQ applications."

      parameter name: :sort,
                in: :query,
                schema: {
                  "$ref": "#/components/schemas/NPQApplicationsSort",
                },
                style: :form,
                explode: false,
                required: false,
                description: "Sort NPQ applications being returned.",
                example: "sort=-updated_at"

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

  path "/api/v3/npq-applications/{id}" do
    get "Get a single NPQ application" do
      operationId :npq_application
      tags "NPQ applications"
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

        after do |example|
          content = example.metadata[:response][:content] || {}

          example_spec = {
            "application/json" => {
              examples: {
                success: {
                  value: JSON.parse({
                    data: {
                      id: "db3a7848-7308-4879-942a-c4a70ced400a",
                      type: "npq_application",
                      attributes: {
                        course_identifier: "npq-leading-teaching-development",
                        email: "isabelle.macdonald2@some-school.example.com",
                        email_validated: true,
                        employer_name: nil,
                        employment_role: nil,
                        full_name: "Isabelle MacDonald",
                        funding_choice: nil,
                        headteacher_status: nil,
                        ineligible_for_funding_reason: nil,
                        participant_id: "53847955-7cfg-41eb-a322-96c50adc742b",
                        private_childcare_provider_urn: nil,
                        teacher_reference_number: "0743795",
                        teacher_reference_number_validated: true,
                        school_urn: "123456",
                        school_ukprn: "12345678",
                        status: "pending",
                        works_in_school: true,
                        created_at: "2022-07-06T10:47:24Z",
                        updated_at: "2022-11-24T17:09:37Z",
                        cohort: "2022",
                        eligible_for_funding: true,
                        targeted_delivery_funding_eligibility: false,
                        teacher_catchment: true,
                        teacher_catchment_iso_country_code: "GBR",
                        teacher_catchment_country: "United Kingdom of Great Britain and Northern Ireland",
                        itt_provider: nil,
                        lead_mentor: false,
                      },
                    },
                  }.to_json, symbolize_names: true),
                },
              },
            },
          }

          example.metadata[:response][:content] = content.deep_merge(example_spec)
        end

        run_test!
      end

      response "401", "Unauthorized" do
        let(:id) { npq_application.id }
        let(:Authorization) { "Bearer invalid" }

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

  path "/api/v3/npq-applications/{id}/accept" do
    post "Accept an NPQ application" do
      operationId :npq_applications_accept
      tags "NPQ applications"
      security [bearerAuth: []]

      parameter name: :id,
                in: :path,
                required: true,
                example: "28c461ee-ffc0-4e56-96bd-788579a0ed75",
                description: "The ID of the NPQ application to accept.",
                schema: {
                  type: "string",
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

      response "404", "Not Found", exceptions_app: true do
        let(:id) { "test" }

        schema({ "$ref": "#/components/schemas/NotFoundResponse" })

        run_test!
      end

      response "422", "Unprocessable Entity" do
        let(:id) { npq_application.id }

        before { npq_application.update(lead_provider_approval_status: "accepted") }

        schema({ "$ref": "#/components/schemas/NPQApplicationAcceptErrorResponse" })

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

      response "404", "Not Found", exceptions_app: true do
        let(:id) { "test" }

        schema({ "$ref": "#/components/schemas/NotFoundResponse" })

        run_test!
      end

      response "422", "Unprocessable Entity" do
        let(:id) { npq_application.id }

        before { npq_application.update(lead_provider_approval_status: "rejected") }

        schema({ "$ref": "#/components/schemas/NPQApplicationAcceptErrorResponse" })

        run_test!
      end
    end
  end
end
