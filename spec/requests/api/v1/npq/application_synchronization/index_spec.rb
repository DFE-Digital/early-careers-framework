# frozen_string_literal: true

require "rails_helper"
RSpec.describe "NPQ Application Status API", type: :request do
  let(:cpd_lead_provider) { create(:cpd_lead_provider) }
  let(:token)             { NPQRegistrationApiToken.create_with_random_token!(cpd_lead_provider_id: cpd_lead_provider.id) }
  let(:bearer_token)      { "Bearer #{token}" }
  let(:parsed_response) { JSON.parse(response.body)["data"].first }

  before { default_headers[:Authorization] = bearer_token }

  describe "GET /api/v1/npq/application_synchronizations" do
    let(:npq_application) { create(:npq_application, :accepted) }
    let(:pick_application) { NPQApplication.where(id: npq_application.id).pick(:lead_provider_approval_status, :id, :participant_identity_id) }
    let(:declaration_date) { npq_application.profile.schedule.milestones.find_by(declaration_type: "completed").start_date }
    let!(:participant_declaration) do
      travel_to declaration_date + 2.days do
        create(:npq_participant_declaration, declaration_type: "completed", cpd_lead_provider: npq_application.npq_lead_provider.cpd_lead_provider, participant_profile: npq_application.profile, declaration_date:)
      end
    end
    let!(:participant_outcome) { create(:participant_outcome, :failed, participant_declaration:) }

    it_behaves_like "Feature enabled NPQ API endpoint", "GET", "/api/v1/npq/application_synchronizations"

    it "returns correct jsonapi content" do
      @controller = Api::V1::NPQ::ApplicationSynchronizationsController.new
      @controller.params = { "@npq_applications": npq_application }

      get "/api/v1/npq/application_synchronizations"

      expect(parsed_response).to be_a(Hash)
      expect(parsed_response["attributes"]["id"]).to eq(npq_application.id.to_s)
      expect(parsed_response["attributes"]["lead_provider_approval_status"]).to eq("accepted")
      expect(parsed_response["attributes"]["participant_outcome_state"]).to eq("failed")
    end
  end
end
