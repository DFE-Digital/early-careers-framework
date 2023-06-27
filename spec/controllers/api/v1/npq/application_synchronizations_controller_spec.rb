# frozen_string_literal: true

require "rails_helper"

class DummyController < Api::V1::NPQ::ApplicationSynchronizationsController
  include ApiTokenAuthenticatable
end

describe DummyController, type: :controller do
  describe "#authenticate" do
    before do
      controller.response              = response
      request.headers["Authorization"] = bearer_token
      controller.authenticate
    end

    context "when authorization header not provided or invalid" do
      let(:bearer_token) { "Bearer invalid" }

      it "requests authentication via the http header" do
        expect(response.status).to eq(401)
      end
    end

    context "when authorization header is provided" do
      let(:cpd_lead_provider) { create(:cpd_lead_provider) }
      let(:token) { NPQRegistrationApiToken.create_with_random_token!(cpd_lead_provider_id: cpd_lead_provider.id) }
      let(:bearer_token) { "Bearer #{token}" }

      it "requests authentication via the http header" do
        expect(response.status).to eq(200)
      end
    end
  end
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
        @controller = Api::V1::NPQ::ApplicationSynchronizationsController.new
        @controller.params = { "@npq_applications": npq_application }
        get :index
        json_response = JSON.parse(response.body)
        expect(json_response["data"]).to be_an(Array)
        expect(json_response["data"].size).to eq(1)
        expect(json_response["data"].first["id"]).to eq(npq_application.id.to_s)
      end
    end
  end
end
