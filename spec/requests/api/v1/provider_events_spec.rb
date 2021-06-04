# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Participant Declarations", type: :request do
  describe "participant-declarations" do
    let(:lead_provider) { create(:lead_provider) }
    let(:token) { LeadProviderApiToken.create_with_random_token!(lead_provider: lead_provider) }
    let(:bearer_token) { "Bearer #{token}" }
    let(:payload) { create(:early_career_teacher_profile) }
    let(:params) {
      {
        participant_id: payload.user_id,
        declaration_type: "Start",
        declaration_date: (DateTime.now-1.week).iso8601
      }
    }
    let(:invalid_user_id) {
      {
        participant_id: payload.id,
        declaration_type: "Start",
        declaration_date: (DateTime.now-1.week).iso8601
      }
    }
    let(:missing_user_id) {
      {
        participant_id: nil,
        declaration_type: "Start",
        declaration_date: (DateTime.now-1.week).iso8601
      }
    }
    let(:missing_required_parameter) {
      {
        declaration_type: "Start",
        declaration_date: (DateTime.now-1.week).iso8601
      }
    }

    let(:parsed_response) { JSON.parse(response.body) }

    context "when authorized" do
      before do
        default_headers[:Authorization] = bearer_token
      end

      it "returns 204 status when successful" do
        post "/api/v1/participant-declarations", params: params
        expect(response.status).to eq 204
      end

      it "returns 404 when trying to create for an invalid user id" do # Expectes the user uuid. Pass the early_career_teacher_profile_id
        post "/api/v1/participant-declarations", params: invalid_user_id
        expect(response.status).to eq 404
      end

      it "returns 404 when trying to create with no id" do
        post "/api/v1/participant-declarations", params: missing_user_id
        expect(response.status).to eq 404
      end

      it "returns 422 when a required parameter is missing" do
        post "/api/v1/participant-declarations", params: missing_required_parameter
        expect(response.status).to eq 422
        expect(response.body).to eq({missing_parameter: ["participant_id"]}.to_json)
      end
    end

    context "when unauthorized" do
      it "returns 401 for invalid bearer token" do
        default_headers[:Authorization] = "Bearer ugLPicDrpGZdD_w7hhCL"
        post "/api/v1/participant-declarations", params: params
        expect(response.status).to eq 401
      end
    end
  end
end
