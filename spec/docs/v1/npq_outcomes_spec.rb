# frozen_string_literal: true

require "swagger_helper"

describe "API", :with_default_schedules, type: :request, swagger_doc: "v1/api_spec.json" do
  let(:cpd_lead_provider) { create(:cpd_lead_provider, :with_npq_lead_provider) }
  let(:token) { LeadProviderApiToken.create_with_random_token!(cpd_lead_provider:) }
  let(:Authorization) { "Bearer #{token}" }
  let(:npq_course) { create(:npq_course, identifier: "npq-senior-leadership") }
  let(:npq_declaration) { create(:npq_participant_declaration, npq_course:, cpd_lead_provider:) }
  let(:participant_profile) { npq_declaration.participant_profile }

  path "/api/v1/participants/npq/{participant_id}/outcomes" do
    post "Submit a NPQ outcome" do
      operationId :npq_outcome_post
      tags "NPQ outcomes"
      security [bearerAuth: []]
      consumes "application/json"

      request_body content: {
        "application/json": {
          "schema": {
            "$ref": "#/components/schemas/NPQOutcomeRequest",
          },
        },
      }

      parameter name: :participant_id,
                description: "The unique ID of the participant",
                in: :path,
                required: true,
                schema: {
                  type: :string,
                  format: :uuid,
                },
                example: "70885c85-f52b-45fe-b969-e09a93ffc6ee"

      parameter name: :params,
                in: :body,
                type: :object,
                style: :deepObject,
                required: true,
                schema: {
                  "$ref": "#/components/schemas/NPQOutcomeRequest",
                }

      response "200", "Successfully submit a NPQ outcome" do
        let(:participant_id) { participant_profile.participant_identity.external_identifier }
        let(:attributes) do
          {
            state: ParticipantOutcome::NPQ::PERMITTED_STATES.map(&:to_s).sample,
            course_identifier: npq_declaration.course_identifier,
            completion_date: npq_declaration.declaration_date.rfc3339,
          }
        end

        let(:params) do
          {
            "data": {
              "type": "npq-outcome-confirmation",
              "attributes": attributes,
            },
          }
        end

        before { npq_declaration.update!(declaration_type: "completed") }

        schema({ "$ref": "#/components/schemas/NPQOutcomeResponse" })

        run_test!
      end

      response "401", "Unauthorized" do
        let(:Authorization) { "Bearer invalid" }
        let(:participant_id) { participant_profile.participant_identity.external_identifier }

        schema({ "$ref": "#/components/schemas/UnauthorisedResponse" })

        run_test!
      end
    end
  end
end
