# frozen_string_literal: true

require "swagger_helper"

require_relative "../../shared/context/lead_provider_profiles_and_courses"

describe "API", type: :request, swagger_doc: "v3/api_spec.json" do
  include_context "lead provider profiles and courses"

  let(:token) { LeadProviderApiToken.create_with_random_token!(cpd_lead_provider:) }
  let(:bearer_token) { "Bearer #{token}" }
  let(:Authorization) { bearer_token }

  path "/api/v3/participants/ecf" do
    get "Retrieve multiple participants, replaces <code>/api/v3/participants</code>" do
      operationId :participants
      tags "ECF participants"
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
                description: "Refine ECF participants to return.",
                example: CGI.unescape({ filter: { cohort: 2022, updated_since: "2020-11-13T11:21:55Z" } }.to_param)

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
                description: "Pagination options to navigate through the list of ECF participants."

      response "200", "A list of ECF participants" do
        schema({ "$ref": "#/components/schemas/MultipleECFParticipantsResponse" })

        run_test!
      end

      response "401", "Unauthorized" do
        let(:Authorization) { "Bearer invalid" }

        schema({ "$ref": "#/components/schemas/UnauthorisedResponse" })

        run_test!
      end
    end
  end

  path "/api/v3/participants/ecf/{id}" do
    get "Get a single ECF participant" do
      operationId :ecf_participant
      tags "ECF participants"
      security [bearerAuth: []]

      parameter name: :id,
                in: :path,
                type: :string,
                required: true,
                example: "28c461ee-ffc0-4e56-96bd-788579a0ed75",
                description: "The ID of the ECF participant."

      response "200", "A single ECF participant" do
        let(:id) { mentor_profile.user.id }

        schema({ "$ref": "#/components/schemas/ECFParticipantResponse" })

        run_test!
      end

      response "401", "Unauthorized" do
        let(:id) { mentor_profile.user.id }
        let(:Authorization) { "Bearer invalid" }

        schema({ "$ref": "#/components/schemas/UnauthorisedResponse" })

        run_test!
      end
    end
  end

  path "/api/v3/participants/ecf/{id}/defer" do
    put "Notify that an ECF participant is taking a break from their course" do
      operationId "ecf_participant_defer"
      tags "ECF Participant"
      security [bearerAuth: []]
      consumes "application/json"

      request_body content: {
        "application/json": {
          "schema": {
            "$ref": "#/components/schemas/ECFParticipantDeferRequest",
          },
        },
      }

      parameter name: :id,
                in: :path,
                type: :string,
                required: true,
                example: "28c461ee-ffc0-4e56-96bd-788579a0ed75",
                description: "The ID of the participant to defer"

      parameter name: :params,
                in: :body,
                type: :object,
                style: :deepObject,
                required: true,
                schema: {
                  "$ref": "#/components/schemas/ECFParticipantDeferRequest",
                }

      response "200", "The ECF participant being deferred" do
        let(:id) { mentor_profile.user.id }

        let(:params) do
          {
            data: {
              type: "participant",
              attributes: {
                reason: "career-break",
                course_identifier: "ecf-mentor",
              },
            },
          }
        end

        schema({ "$ref": "#/components/schemas/ECFParticipantResponse" })

        # TODO: replace with actual implementation once implemented
        after do |example|
          content = example.metadata[:response][:content] || {}
          example_spec = {
            "application/json" => {
              examples: {
                success: {
                  value: JSON.parse({
                    data: {
                      id: "db3a7848-7308-4879-942a-c4a70ced400a",
                      type: "participant",
                      attributes: {
                        email: "jane.smith@some-school.example.com",
                        full_name: "Jane Smith",
                        mentor_id: "bb36d74a-68a7-47b6-86b6-1fd0d141c590",
                        school_urn: "106286",
                        participant_type: "ect",
                        cohort: "2021",
                        teacher_reference_number: "1234567",
                        teacher_reference_number_validated: true,
                        eligible_for_funding: true,
                        pupil_premium_uplift: true,
                        sparsity_uplift: true,
                        training_status: "deferred",
                        schedule_identifier: "ecf-standard-january",
                        updated_at: "2021-05-31T02:22:32.000Z",
                        withdrawal_date: nil,
                        participant_status: "active",
                        validation_status: "eligible_to_start",
                        joining_date: "2022-05-09T16:07:10Z",
                        leaving_date: "2022-11-09T16:07:38Z",
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
    end
  end

  it_behaves_like "JSON Participant resume documentation",
                  "/api/v3/participants/ecf/{id}/resume",
                  "#/components/schemas/ECFParticipantResumeRequest",
                  "#/components/schemas/ECFParticipantResumeResponse",
                  "ECF Participant" do
    let(:participant) { deferred_mentor_profile }
    let!(:mentor_induction_record_deferred) { create(:induction_record, induction_programme:, participant_profile: deferred_mentor_profile, training_status: "deferred") }
    let(:attributes) { { course_identifier: "ecf-mentor" } }
  end

  path "/api/v3/participants/ecf/{id}/withdraw" do
    put "Notify that an ECF participant has withdrawn from their course" do
      operationId :participant
      tags "ECF Participant"
      security [bearerAuth: []]
      consumes "application/json"

      request_body content: {
        "application/json": {
          "schema": {
            "$ref": "#/components/schemas/ECFParticipantWithdrawRequest",
          },
        },
      }

      parameter name: :id,
                in: :path,
                type: :string,
                required: true,
                example: "28c461ee-ffc0-4e56-96bd-788579a0ed75",
                description: "The ID of the participant to withdraw"

      parameter name: :params,
                in: :body,
                type: :object,
                style: :deepObject,
                required: true,
                schema: {
                  "$ref": "#/components/schemas/ECFParticipantWithdrawRequest",
                }

      response "200", "The ECF participant being withdrawn" do
        let(:id) { mentor_profile.user.id }
        let(:attributes) do
          {
            reason: "left-teaching-profession",
            course_identifier: "ecf-mentor",
          }
        end

        let(:params) do
          {
            "data": {
              "type": "participant",
              "attributes": attributes,
            },
          }
        end

        schema({ "$ref": "#/components/schemas/ECFParticipantWithdrawResponse" })

        run_test!
      end
    end
  end

  it_behaves_like "JSON Participant Change schedule documentation",
                  "/api/v3/participants/ecf/{id}/change-schedule",
                  "#/components/schemas/ECFParticipantChangeScheduleRequest",
                  "#/components/schemas/ECFParticipantResponse",
                  "ECF Participant",
                  :with_default_schedules do
    let(:participant) { mentor_profile }
    let(:attributes) do
      {
        schedule_identifier: "ecf-standard-september",
        course_identifier: "ecf-mentor",
      }
    end
  end
end
