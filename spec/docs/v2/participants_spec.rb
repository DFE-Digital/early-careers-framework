# frozen_string_literal: true

require "swagger_helper"

require_relative "../../shared/context/lead_provider_profiles_and_courses"

describe "API", type: :request, swagger_doc: "v2/api_spec.json" do
  include_context "lead provider profiles and courses"

  let(:token) { LeadProviderApiToken.create_with_random_token!(cpd_lead_provider:) }
  let(:bearer_token) { "Bearer #{token}" }
  let(:Authorization) { bearer_token }

  it_behaves_like "JSON Participant Deferral documentation",
                  "/api/v2/participants/{id}/defer",
                  "#/components/schemas/ECFParticipantDeferRequest",
                  "#/components/schemas/ECFParticipantResponse",
                  "ECF Participant" do
    let(:participant) { mentor_profile }
    let(:attributes) do
      {
        reason: "career-break",
        course_identifier: "ecf-mentor",
      }
    end
  end

  it_behaves_like "JSON Participant resume documentation",
                  "/api/v2/participants/{id}/resume",
                  "#/components/schemas/ECFParticipantResumeRequest",
                  "#/components/schemas/ECFParticipantResponse",
                  "ECF Participant" do
    let(:participant) { mentor_profile }
    let(:attributes) { { course_identifier: "ecf-mentor" } }
  end

  path "/api/v2/participants/{id}/withdraw" do
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

        schema({ "$ref": "#/components/schemas/ECFParticipantResponse" })
        run_test!
      end
    end
  end

  it_behaves_like "JSON Participant Change schedule documentation",
                  "/api/v2/participants/{id}/change-schedule",
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
