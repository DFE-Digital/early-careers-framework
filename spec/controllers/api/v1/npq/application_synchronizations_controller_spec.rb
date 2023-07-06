# frozen_string_literal: true

require "rails_helper"

class NPQDummyController < Api::V1::NPQ::ApplicationSynchronizationsController
  include ApiTokenAuthenticatable
end

describe NPQDummyController, type: :controller do
  describe "Get#index" do
    before do
      controller.response              = response
      request.headers["Authorization"] = bearer_token
      controller.authenticate
    end

    context "when authorization header is provided" do
      let(:cpd_lead_provider) { create(:cpd_lead_provider) }
      let(:token) { NPQRegistrationApiToken.create_with_random_token!(cpd_lead_provider_id: cpd_lead_provider.id) }
      let(:bearer_token) { "Bearer #{token}" }
      let(:npq_application) { create(:npq_application) }

      it "renders JSON response with serialized NPQ applications" do
        allow(Api::V1::NPQ::ApplicationStatusQuery).to receive(:new).and_call_original
        allow_any_instance_of(Api::V1::NPQ::ApplicationStatusQuery).to receive(:call).and_return({
          "npq_application" => [
            npq_application.lead_provider_approval_status,
            npq_application.id.to_s,
          ],
          "participant_outcome_state" => NPQApplication.participant_declaration_finder(npq_application)&.latest_outcome_state_of_declaration,
        })
        @controller = Api::V1::NPQ::ApplicationSynchronizationsController.new
        @controller.params = { "@npq_applications": npq_application }
        get :index
        json_response = JSON.parse(response.body)
        npq_applications = []
        npq_applications << npq_application
        expect(json_response).to be_a(Hash)
        expect(json_response["npq_application"][1]).to eq(npq_application.id.to_s)
        expect(json_response["npq_application"][0]).to eq(npq_application.lead_provider_approval_status)
        expect(json_response["participant_outcome_state"]).to eq(NPQApplication.participant_declaration_finder(npq_applications)&.latest_outcome_state_of_declaration)
      end
    end
  end
end
