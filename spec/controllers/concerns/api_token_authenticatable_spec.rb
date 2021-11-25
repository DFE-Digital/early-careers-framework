# frozen_string_literal: true

require "rails_helper"

RSpec.describe ApiTokenAuthenticatable, type: :controller do
  controller(ApplicationController) do
    include ApiTokenAuthenticatable

    def index
      head :ok
    end
  end

  describe "#authenticate" do
    before do
      request.headers["Accept"] = "application/json"
    end

    context "when authorization header not present" do
      let(:bearer_token) { "Bearer invalid" }

      it "returns 401" do
        get :index
        expect(response.status).to eql(401)
        expect(JSON.parse(response.body)).to eql({ "errors" => [{ "title" => "Unauthorized" }] })
      end
    end

    context "when authorization header invalid" do
      before do
        request.headers["Authorization"] = bearer_token
      end

      let(:bearer_token) { "Bearer invalid" }

      it "returns 401" do
        get :index
        expect(response.status).to eql(401)
      end
    end

    context "when authorization header is provided" do
      let(:lead_provider) { create(:lead_provider) }
      let(:token) { LeadProviderApiToken.create_with_random_token!(lead_provider: lead_provider) }
      let(:bearer_token) { "Bearer #{token}" }

      before do
        request.headers["Authorization"] = bearer_token
      end

      it "passes through" do
        get :index
        expect(response.status).to eql(200)
      end
    end
  end
end
