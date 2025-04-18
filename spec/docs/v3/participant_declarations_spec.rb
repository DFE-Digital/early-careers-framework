# frozen_string_literal: true

require "swagger_helper"

RSpec.describe "Participant Declarations", type: :request, swagger_doc: "v3/api_spec.json" do
  let(:ect_profile) { create(:ect) }
  let(:ect_declaration_date) { ect_profile.schedule.milestones.find_by(declaration_type: "started").start_date }
  let(:user) { ect_profile.user }
  let(:cpd_lead_provider) { ect_profile.current_induction_records.first.cpd_lead_provider }
  let(:token) { LeadProviderApiToken.create_with_random_token!(cpd_lead_provider:) }
  let(:bearer_token) { "Bearer #{token}" }
  let(:Authorization) { bearer_token }

  before do
    travel_to ect_profile.schedule.milestones.first.start_date + 2.days
  end

  path "/api/v3/participant-declarations" do
    get "<b>Note, this endpoint includes updated specifications.</b><br/>List all participant declarations" do
      operationId :participant_declarations
      tags "Participant declarations"
      produces "application/json"
      security [bearerAuth: []]

      parameter name: :filter,
                in: :query,
                schema: {
                  "$ref": "#/components/schemas/ParticipantDeclarationsFilter",
                },
                style: :deepObject,
                explode: true,
                required: false,
                description: "Refine participant declarations to return.",
                example: CGI.unescape({
                  filter: {
                    participant_id: "ab3a7848-1208-7679-942a-b4a70eed400a",
                    updated_since: "2020-11-13T11:21:55Z",
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
                description: "Pagination options to navigate through the list of participant declarations."

      response "200", "A list of participant declarations" do
        schema({ "$ref": "#/components/schemas/MultipleParticipantDeclarationsResponse" })

        after do |example|
          content = example.metadata[:response][:content] || {}
          example_spec = {
            "application/json" => {
              examples: {
                success: {
                  value: {
                    data: [
                      {
                        id: "db3a7848-7308-4879-942a-c4a70ced400a",
                        type: "participant-declaration",
                        attributes: {
                          participant_id: "08d78829-f864-417f-8a30-cb7655714e28",
                          declaration_type: "started",
                          declaration_date: "2020-11-13T11:21:55Z",
                          course_identifier: "ecf-induction",
                          state: "eligible",
                          updated_at: "2020-11-13T11:21:55Z",
                          created_at: "2020-11-13T11:21:55Z",
                          delivery_partner_id: "99ca2223-8c1f-4ac8-985d-a0672e97694e",
                          statement_id: "99ca2223-8c1f-4ac8-985d-a0672e97694e",
                          clawback_statement_id: nil,
                          ineligible_for_funding_reason: nil,
                          mentor_id: "907f61ed-5770-4d38-b22c-1a4265939378",
                          uplift_paid: true,
                          evidence_held: "other",
                          has_passed: nil,
                          lead_provider_name: "Example Institute",
                        },
                      },
                    ],
                  },
                },
              },
            },
          }
          example.metadata[:response][:content] = content.deep_merge(example_spec)
        end

        run_test!
      end

      response "401", "Unauthorized" do
        let(:Authorization) { "Bearer invalid" }

        schema({ "$ref": "#/components/schemas/UnauthorisedResponse" })

        run_test!
      end
    end
  end

  path "/api/v3/participant-declarations" do
    post "<b>Note, this endpoint includes updated specifications.</b><br/>Declare a participant has reached a milestone. Idempotent endpoint - submitting exact copy of a request will return the same response body as submitting it the first time." do
      operationId :participant_declaration_create
      tags "Participant declarations"
      consumes "application/json"
      produces "application/json"
      security [bearerAuth: []]

      parameter name: :params,
                in: :body,
                style: :deepObject,
                required: true,
                schema: {
                  "$ref": "#/components/schemas/ParticipantDeclarationRequest",
                }

      response 200, "Successful" do
        let(:attributes) do
          {
            participant_id: ect_profile.user.id,
            declaration_date: ect_declaration_date.rfc3339,
            declaration_type: "started",
            course_identifier: "ecf-induction",
          }
        end

        let(:params) do
          {
            "data": {
              "type": "participant-declaration",
              "attributes": attributes,
            },
          }
        end

        schema({ "$ref": "#/components/schemas/SingleParticipantDeclarationResponse" })

        after do |example|
          content = example.metadata[:response][:content] || {}
          example_spec = {
            "application/json" => {
              examples: {
                success_ecf: {
                  value: {
                    data: {
                      id: "db3a7848-7308-4879-942a-c4a70ced400a",
                      type: "participant-declaration",
                      attributes: {
                        participant_id: "08d78829-f864-417f-8a30-cb7655714e28",
                        declaration_type: "started",
                        declaration_date: "2020-11-13T11:21:55Z",
                        course_identifier: "ecf-induction",
                        state: "eligible",
                        updated_at: "2020-11-13T11:21:55Z",
                        created_at: "2020-11-13T11:21:55Z",
                        delivery_partner_id: "99ca2223-8c1f-4ac8-985d-a0672e97694e",
                        statement_id: "99ca2223-8c1f-4ac8-985d-a0672e97694e",
                        clawback_statement_id: nil,
                        ineligible_for_funding_reason: nil,
                        mentor_id: "907f61ed-5770-4d38-b22c-1a4265939378",
                        uplift_paid: true,
                        evidence_held: "other",
                        has_passed: nil,
                        lead_provider_name: "Example Institute",
                      },
                    },
                  },
                },
              },
            },
          }
          example.metadata[:response][:content] = content.deep_merge(example_spec)
        end

        run_test!
      end

      response "422", "Bad or Missing parameter" do
        let(:user) { build(:user, :early_career_teacher) }

        let(:params) do
          {
            "data": {
              "type": "participant-declaration",
              "attributes": {},
            },
          }
        end

        schema({ "$ref": "#/components/schemas/ErrorResponse" })

        run_test!
      end

      response "401", "Unauthorized" do
        let(:Authorization) { "Bearer invalid" }
        let(:params) {}

        schema({ "$ref": "#/components/schemas/UnauthorisedResponse" })

        run_test!
      end

      response "400", "Bad Request" do
        let(:params) {}

        schema({ "$ref": "#/components/schemas/BadRequestResponse" })

        run_test!
      end
    end
  end

  path "/api/v3/participant-declarations/{id}" do
    let(:id) do
      create(
        :ect_participant_declaration,
        user:,
        cpd_lead_provider:,
      ).id
    end

    get "<b>Note, this endpoint includes updated specifications.</b><br/>Get single participant declaration" do
      operationId :participant_declaration
      tags "Participant declarations"
      produces "application/json"
      security [bearerAuth: []]

      parameter name: :id,
                in: :path,
                required: true,
                example: "9ed4612b-f8bd-44d9-b296-38ab103fadd2",
                description: "The ID of the participant declaration ID",
                schema: {
                  type: :string,
                  format: :uuid,
                }

      response "200", "A single participant declaration" do
        schema({ "$ref": "#/components/schemas/SingleParticipantDeclarationResponse" })

        after do |example|
          content = example.metadata[:response][:content] || {}
          example_spec = {
            "application/json" => {
              examples: {
                success_ecf: {
                  value: {
                    data: {
                      id: "db3a7848-7308-4879-942a-c4a70ced400a",
                      type: "participant-declaration",
                      attributes: {
                        participant_id: "08d78829-f864-417f-8a30-cb7655714e28",
                        declaration_type: "started",
                        declaration_date: "2020-11-13T11:21:55Z",
                        course_identifier: "ecf-induction",
                        state: "eligible",
                        updated_at: "2020-11-13T11:21:55Z",
                        created_at: "2020-11-13T11:21:55Z",
                        delivery_partner_id: "99ca2223-8c1f-4ac8-985d-a0672e97694e",
                        statement_id: "99ca2223-8c1f-4ac8-985d-a0672e97694e",
                        clawback_statement_id: nil,
                        ineligible_for_funding_reason: nil,
                        mentor_id: "907f61ed-5770-4d38-b22c-1a4265939378",
                        uplift_paid: true,
                        evidence_held: "other",
                        has_passed: nil,
                        lead_provider_name: "Example Institute",
                      },
                    },
                  },
                },
              },
            },
          }
          example.metadata[:response][:content] = content.deep_merge(example_spec)
        end

        run_test!
      end

      response "401", "Unauthorized" do
        let(:Authorization) { "Bearer invalid" }

        schema({ "$ref": "#/components/schemas/UnauthorisedResponse" })

        run_test!
      end

      response "404", "Not found", exceptions_app: true do
        let(:id) { "aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee" }

        schema({ "$ref": "#/components/schemas/NotFoundResponse" })

        run_test!
      end
    end
  end

  path "/api/v3/participant-declarations/{id}/void" do
    put "<b>Note, this endpoint includes updated specifications.</b><br/>Void a declaration - it will not be soft-deleted" do
      operationId :participant_declaration_void
      tags "Participant declarations"
      consumes "application/json"
      produces "application/json"
      security [bearerAuth: []]

      parameter name: :id,
                in: :path,
                required: true,
                example: "28c461ee-ffc0-4e56-96bd-788579a0ed75",
                description: "The ID of the declaration to void",
                schema: {
                  type: :string,
                  format: :uuid,
                }

      response 200, "Successful" do
        let(:id) do
          declaration = create(:participant_declaration, user: ect_profile.user, cpd_lead_provider:, course_identifier: "ecf-induction", participant_profile: ect_profile)
          declaration.id
        end

        schema({ "$ref": "#/components/schemas/SingleParticipantDeclarationResponse" })

        after do |example|
          content = example.metadata[:response][:content] || {}
          example_spec = {
            "application/json" => {
              examples: {
                success_ecf: {
                  value: {
                    data: {
                      id: "db3a7848-7308-4879-942a-c4a70ced400a",
                      type: "participant-declaration",
                      attributes: {
                        participant_id: "08d78829-f864-417f-8a30-cb7655714e28",
                        declaration_type: "started",
                        declaration_date: "2020-11-13T11:21:55Z",
                        course_identifier: "ecf-induction",
                        state: "voided",
                        updated_at: "2020-11-13T11:21:55Z",
                        created_at: "2020-11-13T11:21:55Z",
                        delivery_partner_id: "99ca2223-8c1f-4ac8-985d-a0672e97694e",
                        statement_id: "99ca2223-8c1f-4ac8-985d-a0672e97694e",
                        clawback_statement_id: nil,
                        ineligible_for_funding_reason: nil,
                        mentor_id: "907f61ed-5770-4d38-b22c-1a4265939378",
                        uplift_paid: true,
                        evidence_held: "other",
                        has_passed: nil,
                        lead_provider_name: "Example Institute",
                      },
                    },
                  },
                },
              },
            },
          }
          example.metadata[:response][:content] = content.deep_merge(example_spec)
        end

        run_test!
      end
    end
  end
end
