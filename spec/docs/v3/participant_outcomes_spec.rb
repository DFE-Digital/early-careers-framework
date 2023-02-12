# frozen_string_literal: true

require "swagger_helper"

RSpec.describe "API", :with_default_schedules, type: :request, swagger_doc: "v3/api_spec.json", with_feature_flags: { api_v3: "active" } do
  let(:token)                { LeadProviderApiToken.create_with_random_token!(cpd_lead_provider:) }
  let(:bearer_token)         { "Bearer #{token}" }
  let(:Authorization)     { bearer_token }
  let(:cpd_lead_provider) { create :cpd_lead_provider, :with_npq_lead_provider }
  let(:npq_course) { create(:npq_course, identifier: "npq-senior-leadership") }
  let(:participant_declaration) { create(:npq_participant_declaration, npq_course:, cpd_lead_provider:) }
  let(:participant_profile) { participant_declaration.participant_profile }
  let!(:participant_outcome) { create :participant_outcome, participant_declaration: }
  let(:params) {}

  path "/api/v3/participants/npq/outcomes" do
    get "List all participant NPQ outcomes" do
      operationId :participant_outcomes
      tags "Participants Outcomes"
      security [bearerAuth: []]

      parameter name: :page,
                in: :query,
                schema: {
                  "$ref": "#/components/schemas/Pagination",
                },
                style: :deepObject,
                explode: true,
                required: false,
                example: CGI.unescape({ page: { page: 1, per_page: 5 } }.to_param),
                description: "Pagination options to navigate through the list of participant NPQ outcomes."

      response "200", "A list of participant outcomes" do
        schema({ "$ref": "#/components/schemas/NPQOutcomesResponse" })

        run_test!
      end

      response "401", "Unauthorized" do
        let(:Authorization) { "Bearer invalid" }

        schema({ "$ref": "#/components/schemas/UnauthorisedResponse" })

        run_test!
      end
    end
  end

  path "/api/v3/participants/npq/{participant_id}/outcomes" do
    let(:participant_id) { participant_profile.participant_identity.external_identifier }

    get "List NPQ outcomes for single participant" do
      operationId :participant_outcomes
      tags "Participants Outcomes"
      security [bearerAuth: []]

      parameter name: :participant_id,
                in: :path,
                required: true,
                example: "28c461ee-ffc0-4e56-96bd-788579a0ed75",
                description: "The external ID of the participant"

      parameter name: :page,
                in: :query,
                schema: {
                  "$ref": "#/components/schemas/Pagination",
                },
                style: :deepObject,
                explode: true,
                required: false,
                example: CGI.unescape({ page: { page: 1, per_page: 5 } }.to_param),
                description: "Pagination options to navigate through the list of participant NPQ outcomes."

      response "200", "A list of participant outcomes" do
        schema({ "$ref": "#/components/schemas/NPQOutcomesResponse" })

        run_test!
      end

      response "401", "Unauthorized" do
        let(:Authorization) { "Bearer invalid" }

        schema({ "$ref": "#/components/schemas/UnauthorisedResponse" })

        run_test!
      end
    end

    post "Submit a NPQ outcome for a single participant" do
      operationId :npq_outcome_post
      tags "Participants Outcomes"
      security [bearerAuth: []]
      consumes "application/json"

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
            course_identifier: participant_declaration.course_identifier,
            completion_date: participant_declaration.declaration_date.rfc3339,
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

        before { participant_declaration.update!(declaration_type: "completed") }

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
