# frozen_string_literal: true

require "rails_helper"

RSpec.describe "NPQ Application Status API", type: :request do
  describe "GET /api/v1/npq/application_synchronizations" do
    let(:cpd_lead_provider) { create(:cpd_lead_provider) }
    let(:token) { NPQRegistrationApiToken.create_with_random_token!(cpd_lead_provider_id: cpd_lead_provider.id) }
    let(:npq_applications) { create_list(:npq_application, 2) }
    let(:npq_application_ids) { npq_applications.map(&:id) }
    let(:ecf_ids) { npq_applications.map(&:id).join(",") }
    let(:bearer_token) { "Bearer #{token}" }
    let(:response_data) { JSON.parse(response.body)["data"] }

    before { default_headers[:Authorization] = bearer_token }

    describe "uses the right serializer" do
      before do
        allow(Api::V1::NPQ::ApplicationSynchronizationSerializer).to receive(:new).with(npq_applications).and_call_original
      end

      it "uses the Api::V1::NPQ::ApplicationSynchronizationSerializer" do
        get "/api/v1/npq/application_synchronizations", params: { ecf_ids: }

        expect(Api::V1::NPQ::ApplicationSynchronizationSerializer).to have_received(:new).once.with(npq_applications)
      end
    end

    context "when valid, existing uuids are sent" do
      it "returns correct jsonapi content" do
        get "/api/v1/npq/application_synchronizations", params: { ecf_ids: }

        expect(response_data.map { |r| r["id"] }).to match_array(npq_application_ids)
      end
    end

    context "when a blank entry is included" do
      let(:ecf_ids) { "#{npq_applications.first.id},,#{npq_applications.second.id}" }

      it "ignores it and returns the correct jsonapi content without erroring" do
        get "/api/v1/npq/application_synchronizations", params: { ecf_ids: }

        expect(response_data.size).to eq(2)
        expect(response_data.map { |r| r["id"] }).to match_array(npq_application_ids)
      end
    end
  end
end
