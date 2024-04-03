# frozen_string_literal: true

require "rails_helper"

class DummyController < Api::ApiController
  include ApiTokenAuthenticatable
end

describe DummyController, type: :controller do
  controller { def index; end }

  describe "#authenticate" do
    before do
      request.headers["Authorization"] = bearer_token
      get :index
    end

    context "when authorization header not provided or invalid" do
      let(:bearer_token) { "Bearer invalid" }

      it "requests authentication via the http header" do
        expect(response.status).to eq(401)
      end
    end

    context "when authorization header is provided" do
      let(:lead_provider) { create(:lead_provider) }
      let(:token) { LeadProviderApiToken.create_with_random_token!(lead_provider:) }
      let(:bearer_token) { "Bearer #{token}" }

      it "requests authentication via the http header" do
        expect(response.status).to eq(204)
      end
    end
  end
end
