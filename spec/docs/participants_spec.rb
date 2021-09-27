# frozen_string_literal: true

require "swagger_helper"

require_relative "../shared/context/lead_provider_profiles_and_courses"

describe "API", type: :request, swagger_doc: "v1/api_spec.json", with_feature_flags: { participant_data_api: "active" } do
  include_context "lead provider profiles and courses"

  let(:token) { LeadProviderApiToken.create_with_random_token!(cpd_lead_provider: cpd_lead_provider) }
  let(:bearer_token) { "Bearer #{token}" }
  let(:Authorization) { bearer_token }

  path "/api/v1/participants/{id}/defer" do
    put "Notify that an ECF participant is taking a break from their course" do
      operationId :participant
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
        let(:attributes) do
          {
            reason: "adoption",
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

  path "/api/v1/participants/{id}/resume" do
    put "Notify that an ECF participant is resuming their course" do
      operationId :participant
      tags "ECF Participant"
      security [bearerAuth: []]
      consumes "application/json"

      request_body content: {
        "application/json": {
          "schema": {
            "$ref": "#/components/schemas/ECFParticipantResumeRequest",
          },
        },
      }

      parameter name: :id,
                in: :path,
                type: :string,
                required: true,
                example: "28c461ee-ffc0-4e56-96bd-788579a0ed75",
                description: "The ID of the participant to resume"

      parameter name: :params,
                in: :body,
                type: :object,
                style: :deepObject,
                required: true,
                schema: {
                  "$ref": "#/components/schemas/ECFParticipantResumeRequest",
                }

      response "200", "The ECF participant being resumed" do
        let(:id) { mentor_profile.user.id }
        let(:attributes) do
          {
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

  path "/api/v1/participants/{id}/change-schedule" do
    put "Notify that an ECF participant is changing training schedule" do
      operationId :participant
      tags "ECF Participant"
      security [bearerAuth: []]
      consumes "application/json"

      request_body content: {
        "application/json": {
          "schema": {
            "$ref": "#/components/schemas/ECFParticipantChangeScheduleRequest",
          },
        },
      }

      parameter name: :id,
                in: :path,
                type: :string,
                required: true,
                example: "28c461ee-ffc0-4e56-96bd-788579a0ed75",
                description: "The ID of the participant"

      parameter name: :params,
                in: :body,
                type: :object,
                style: :deepObject,
                required: true,
                schema: {
                  "$ref": "#/components/schemas/ECFParticipantChangeScheduleRequest",
                }

      response "200", "The ECF participant changing schedule" do
        let(:id) { mentor_profile.user.id }
        let(:attributes) do
          {
            schedule_identifier: "ecf-september-extended-2021",
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

        before do
          create(:schedule, schedule_identifier: "ecf-september-extended-2021")
        end

        schema({ "$ref": "#/components/schemas/ECFParticipantResponse" })
        run_test!
      end
    end
  end

  path "/api/v1/participants/{id}/withdraw" do
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
            reason: "career-break",
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
end
