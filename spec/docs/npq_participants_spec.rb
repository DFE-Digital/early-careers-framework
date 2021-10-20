# frozen_string_literal: true

require "swagger_helper"

describe "API", type: :request, swagger_doc: "v1/api_spec.json" do
  let!(:default_schedule) { create(:schedule, :npq_specialist) }
  let(:cpd_lead_provider) { create(:cpd_lead_provider, npq_lead_provider: npq_lead_provider) }
  let(:npq_lead_provider) { create(:npq_lead_provider) }
  let(:token) { LeadProviderApiToken.create_with_random_token!(cpd_lead_provider: cpd_lead_provider) }
  let(:Authorization) { "Bearer #{token}" }
  let!(:npq_application) { create(:npq_application, :accepted, npq_lead_provider: npq_lead_provider) }

  path "/api/v1/participants/npq" do
    get "Retrieve multiple NPQ participants" do
      operationId :npq_participants
      tags "NPQ participants"
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
                description: "Refine NPQ participants to return.",
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
                description: "Pagination options to navigate through the list of NPQ participants."

      response "200", "A list of NPQ participants" do
        schema({ "$ref": "#/components/schemas/MultipleNPQParticipantsResponse" })

        run_test!
      end

      response "401", "Unauthorized" do
        let(:Authorization) { "Bearer invalid" }

        schema({ "$ref": "#/components/schemas/UnauthorisedResponse" })

        run_test!
      end
    end
  end

  it_behaves_like "JSON Participant Deferral documentation", "/api/v1/participants/npq/{id}/defer", "#/components/schemas/NPQParticipantDeferRequest", "#/components/schemas/NPQParticipantProfile" do
    let(:participant) { npq_application }
    let(:attributes) do
      {
        reason: Participants::Defer::NPQ::REASONS.sample,
        course_identifier: npq_application.npq_course.identifier,
      }
    end

    after do

    end
  end

  path "/api/v1/participants/npq/{id}/withdraw" do
    put "Withdrawn a participant from a course" do
      operationId :npq_participants
      tags "NPQ participant"
      security [bearerAuth: []]
      consumes "application/json"

      request_body content: {
        "application/json": {
          "schema": {
            "$ref": "#/components/schemas/NPQParticipantWithdrawRequest",
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
                  "$ref": "#/components/schemas/NPQParticipantWithdrawRequest",
                }

      response "200", "The NPQ participant being withdrawn" do
        let(:id) { npq_application.user_id }
        let(:attributes) do
          {
            reason: Participants::Withdraw::NPQ.reasons.sample,
            course_identifier: npq_application.npq_course.identifier,
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

        schema({ "$ref": "#/components/schemas/NPQParticipantResponse" })
        run_test!
      end

      response "422", "Unprocessable entity" do
        let(:id) { npq_application.user_id }
        let(:attributes) do
          {
            reason: Participants::Withdraw::NPQ.reasons.sample,
            course_identifier: "bogus-course-identifier",
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

        schema({ "$ref": "#/components/schemas/ErrorResponse" })
        run_test!
      end
    end
  end
end
