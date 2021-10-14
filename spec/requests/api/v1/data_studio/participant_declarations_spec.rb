# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Participant declarations data endpoint", type: :request do
  describe "#index" do
    let(:token) { DataStudioApiToken.create_with_random_token! }
    let(:bearer_token) { "Bearer #{token}" }
    let(:parsed_response) { JSON.parse(response.body) }

    let(:cpd_lead_provider) { create :cpd_lead_provider }
    let!(:ect_participant_declarations) { create_list(:ect_participant_declaration, 3, cpd_lead_provider: cpd_lead_provider) }

    context "when authorized" do
      before do
        default_headers[:Authorization] = bearer_token
      end

      it "returns correct jsonapi content type header" do
        get "/api/v1/data-studio/participant-declarations"
        expect(response.headers["Content-Type"]).to eql("application/vnd.api+json")
      end

      it "returns lead provider participant declaration totals" do
        get "/api/v1/data-studio/participant-declarations"
        expect(parsed_response["data"].size).to eq(1)
        expect(parsed_response["data"][0]["attributes"]["count"]).to eq(3)
      end

      it "returns correct type" do
        get "/api/v1/data-studio/participant-declarations"
        expect(parsed_response["data"][0]).to have_type("lead_provider_participant_declarations")
      end

      it "returns IDs" do
        get "/api/v1/data-studio/participant-declarations"
        expect(ect_participant_declarations.map(&:cpd_lead_provider_id).uniq).to match_array parsed_response["data"].map { |item| item["id"] }
      end

      it "has correct attributes" do
        get "/api/v1/data-studio/participant-declarations"
        expect(parsed_response["data"][0]).to have_jsonapi_attributes(*lead_provider_participant_declaration_attributes).exactly
      end
    end

    context "when unauthorized" do
      it "returns 401 for invalid bearer token" do
        default_headers[:Authorization] = "Bearer ugLPicDrpGZdD_w7hhCL"
        get "/api/v1/data-studio/participant-declarations"
        expect(response.status).to eq 401
      end
    end

    context "using a private token from different scope" do
      let(:other_private_token) { NPQRegistrationApiToken.create_with_random_token! }

      it "returns data successfully" do
        default_headers[:Authorization] = "Bearer #{other_private_token}"
        get "/api/v1/data-studio/participant-declarations"
        expect(parsed_response["data"].size).to eq(1)
        expect(response.status).to eq 200
      end
    end

    context "using public token from different scope" do
      let(:lead_provider) { create(:lead_provider) }
      let(:other_token) { LeadProviderApiToken.create_with_random_token!(lead_provider: lead_provider) }

      it "returns 403 for public bearer token" do
        default_headers[:Authorization] = "Bearer #{other_token}"
        get "/api/v1/data-studio/participant-declarations"
        expect(response.status).to eq 403
      end
    end
  end

  def lead_provider_participant_declaration_attributes
    %i[count lead_provider_name]
  end
end
