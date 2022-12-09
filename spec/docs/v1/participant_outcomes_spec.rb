# frozen_string_literal: true

require "swagger_helper"

RSpec.describe "API", :with_default_schedules, type: :request, swagger_doc: "v1/api_spec.json" do
  let(:token)                { LeadProviderApiToken.create_with_random_token!(cpd_lead_provider: provider) }
  let(:bearer_token)         { "Bearer #{token}" }
  let(:provider) { create :cpd_lead_provider, :with_npq_lead_provider }
  let(:npq_application) { create :npq_application, :accepted, npq_lead_provider: provider.npq_lead_provider }
  let(:Authorization)     { bearer_token }
  let(:declaration) { create :npq_participant_declaration, participant_profile: npq_application.profile, cpd_lead_provider: provider }
  let!(:outcome) { create :participant_outcome, participant_declaration: declaration }

  path "/api/v1/participants/npq/outcomes" do
    get "List all participant NPQ outcomes" do
      operationId :participant_outcomes
      tags "participants outcomes"
      security [bearerAuth: []]

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
end
