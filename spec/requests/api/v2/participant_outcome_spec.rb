# frozen_string_literal: true

require "rails_helper"

RSpec.describe "participant outcomes endpoint spec", :with_default_schedules, type: :request do
  let(:token)                { LeadProviderApiToken.create_with_random_token!(cpd_lead_provider: provider) }
  let(:bearer_token)         { "Bearer #{token}" }
  let(:provider) { create :cpd_lead_provider, :with_npq_lead_provider }
  let(:npq_application) { create :npq_application, :accepted, npq_lead_provider: provider.npq_lead_provider }
  let(:declaration) { create :npq_participant_declaration, participant_profile: npq_application.profile, cpd_lead_provider: provider }

  describe "JSON Index Api" do
    context "when authorized" do
      before do
        default_headers[:Authorization] = bearer_token
        default_headers[:CONTENT_TYPE] = "application/json"
      end

      context "when no outcome exists" do
        it "returns empty array" do
          get "/api/v2/participants/npq/outcomes"
          expect(response.status).to eq 200

          expect(parsed_response).to eq("data" => [])
        end
      end

      context "when outcome exists" do
        let(:expected_response) do
          expected_json_response(outcome:, profile: npq_application.profile)
        end
        let!(:outcome) { create :participant_outcome, participant_declaration: declaration }

        it "returns serialised data" do
          get "/api/v2/participants/npq/outcomes"
          expect(response.status).to eq 200

          expect(parsed_response).to eq(expected_response)
        end

        it "returns matching outcomes by participant_external_id" do
          get "/api/v2/participants/npq/#{npq_application.participant_identity.external_identifier}/outcomes"
          expect(response.status).to eq 200

          expect(parsed_response).to eq(expected_response)
        end

        it "doesn't return outcomes unless matching participant_external_id" do
          get "/api/v2/participants/npq/#{SecureRandom.uuid}/outcomes"
          expect(response.status).to eq 200

          expect(parsed_response).to eq("data" => [])
        end
      end

      it "can return paginated data" do
        create :participant_outcome, :failed, participant_declaration: declaration
        create :participant_outcome, :passed, participant_declaration: declaration
        create :participant_outcome, :voided, participant_declaration: declaration
        get "/api/v2/participants/npq/outcomes", params: { page: { per_page: 2, page: 1 } }
        expect(parsed_response["data"].size).to eql(2)

        get "/api/v2/participants/npq/outcomes", params: { page: { per_page: 2, page: 2 } }
        expect(parsed_response["data"].size).to eql(1)
      end
    end

    context "when unauthorized" do
      let(:bearer_token) { "Bearer a43098a098a" }

      it "returns 401 for invalid bearer token" do
        get "/api/v2/participants/npq/outcomes"

        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

private

  def parsed_response
    JSON.parse(response.body)
  end

  def expected_json_response(outcome:, profile:, course_identifier: declaration.course_identifier)
    {
      "data" =>
      [
        single_json_outcome(outcome:, profile:, course_identifier:),
      ],
    }
  end

  def single_json_outcome(outcome:, profile:, course_identifier:)
    {
      "attributes" => {
        "completion_date" => outcome.completion_date.rfc3339,
        "created_at" => outcome.created_at.rfc3339,
        "course_identifier" => course_identifier,
        "state" => outcome.state,
        "participant_id" => profile.npq_application.participant_identity.user_id,
      },
      "id" => outcome.id,
      "type" => "participant-outcome",
    }
  end
end
