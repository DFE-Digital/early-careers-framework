# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Participant Declarations", type: :request do
  describe "participant-declarations" do
    let(:lead_provider) { create(:lead_provider) }
    let(:token) { LeadProviderApiToken.create_with_random_token!(lead_provider: lead_provider) }
    let(:bearer_token) { "Bearer #{token}" }
    let(:payload) { create(:early_career_teacher_profile) }
    let(:delivery_partner) { create(:delivery_partner) }
    let!(:school_cohort) { create(:school_cohort, school: payload.school, cohort: payload.cohort) }
    let!(:partnership) do
      create(:partnership,
             school: payload.school,
             lead_provider: lead_provider,
             cohort: payload.cohort,
             delivery_partner: delivery_partner)
    end
    let(:params) do
      {
        participant_id: payload.user_id,
        declaration_type: "started",
        declaration_date: (Time.zone.now - 1.week).iso8601,
      }
    end
    let(:invalid_user_id) do
      params.merge({ participant_id: payload.id })
    end
    let(:missing_user_id) do
      params.merge({ participant_id: "" })
    end
    let(:missing_required_parameter) do
      params.except(:participant_id)
    end

    let(:parsed_response) { JSON.parse(response.body) }

    context "when authorized" do
      let(:parsed_response) { JSON.parse(response.body) }

      before do
        default_headers[:Authorization] = bearer_token
        default_headers[:CONTENT_TYPE] = "application/json"
      end

      it "create declaration record and return id when successful" do
        expect {
          post "/api/v1/participant-declarations", params: params.to_json
        }.to change(ParticipantDeclaration, :count).by(1)
        expect(response.status).to eq 200
        expect(parsed_response["id"]).to eq(ParticipantDeclaration.order(:created_at).last.id)
      end

      it "returns 422 when trying to create for an invalid user id" do # Expects the user uuid. Pass the early_career_teacher_profile_id
        post "/api/v1/participant-declarations", params: invalid_user_id.to_json
        expect(response.status).to eq 422
      end

      it "returns 422 when trying to create with no id" do
        post "/api/v1/participant-declarations", params: missing_user_id.to_json
        expect(response.status).to eq 422
      end

      it "returns 422 when a required parameter is missing" do
        post "/api/v1/participant-declarations", params: missing_required_parameter.to_json
        expect(response.status).to eq 422
        expect(response.body).to eq({ bad_or_missing_parameters: %w[participant_id] }.to_json)
      end
    end

    context "when unauthorized" do
      it "returns 401 for invalid bearer token" do
        default_headers[:Authorization] = "Bearer ugLPicDrpGZdD_w7hhCL"
        post "/api/v1/participant-declarations", params: params.to_json
        expect(response.status).to eq 401
      end
    end
  end
end
