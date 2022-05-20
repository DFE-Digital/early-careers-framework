# frozen_string_literal: true

require "rails_helper"

RSpec.describe "NPQ Funding API", type: :request do
  let(:token) { NPQRegistrationApiToken.create_with_random_token!(private_api_access: true) }
  let(:bearer_token) { "Bearer #{token}" }
  let(:parsed_response) { JSON.parse(response.body) }

  describe "GET /api/v1/npq-funding" do
    context "when authorized" do
      before do
        default_headers[:Authorization] = bearer_token
      end

      it "returns correct response" do
        expect(NPQ::FundingEligibility).to receive(:new)
          .with(trn: "1234567", npq_course_identifier: "npq-leading-literacy")
          .and_call_original

        get "/api/v1/npq-funding/1234567?npq_course_identifier=npq-leading-literacy"
        expect(parsed_response["previously_funded"]).to be(false)
      end
    end

    context "when unauthorized" do
      it "returns 401 for invalid bearer token" do
        default_headers[:Authorization] = "Bearer ugLPicDrpGZdD_w7hhCL"
        get "/api/v1/npq-funding/1234567"
        expect(response.status).to eq 401
      end
    end
  end
end
