# frozen_string_literal: true

require "rails_helper"

RSpec.describe "School rollout data endpoint", type: :request do
  describe "#index" do
    let(:token) { DataStudioApiToken.create_with_random_token! }
    let(:bearer_token) { "Bearer #{token}" }
    let(:parsed_response) { JSON.parse(response.body) }

    let(:schools) { create_list(:school, 3) }
    let(:ineligible_school) { create(:school, school_type_code: 99) }

    before do
      schools
      ineligible_school
    end

    context "when authorized" do
      before do
        default_headers[:Authorization] = bearer_token
      end

      it "returns correct jsonapi content type header" do
        get "/api/v1/data-studio/school-rollout"
        expect(response.headers["Content-Type"]).to eql("application/vnd.api+json")
      end

      it "returns all eligible schools" do
        get "/api/v1/data-studio/school-rollout"
        expect(parsed_response["data"].size).to eq(3)
        expect(ineligible_school.id).not_to be_in parsed_response["data"].map { |item| item["id"] }
      end

      it "returns correct type" do
        get "/api/v1/data-studio/school-rollout"
        expect(parsed_response["data"][0]).to have_type("school_rollout")
      end

      it "returns IDs" do
        get "/api/v1/data-studio/school-rollout"
        expect(schools.pluck(:id)).to match_array parsed_response["data"].map { |item| item["id"] }
      end

      it "has correct attributes" do
        get "/api/v1/data-studio/school-rollout"
        expect(parsed_response["data"][0]).to have_jsonapi_attributes(*school_rollout_attributes).exactly
      end
    end

    context "when unauthorized" do
      it "returns 401 for invalid bearer token" do
        default_headers[:Authorization] = "Bearer ugLPicDrpGZdD_w7hhCL"
        get "/api/v1/data-studio/school-rollout"
        expect(response.status).to eq 401
      end
    end

    context "using a private token from different scope" do
      let(:other_private_token) { NpqRegistrationApiToken.create_with_random_token! }

      it "returns data successfully" do
        default_headers[:Authorization] = "Bearer #{other_private_token}"
        get "/api/v1/data-studio/school-rollout"
        expect(parsed_response["data"].size).to eq(3)
        expect(response.status).to eq 200
      end
    end

    context "using public token from different scope" do
      let(:other_token) { EngageAndLearnApiToken.create_with_random_token! }

      it "returns 401 for invalid bearer token" do
        default_headers[:Authorization] = "Bearer #{other_token}"
        get "/api/v1/data-studio/school-rollout"
        expect(response.status).to eq 401
      end
    end
  end

  def school_rollout_attributes
    %i[urn name sent_at opened_at notify_status induction_tutor_nominated tutor_nominated_time induction_tutor_signed_in induction_programme_choice programme_chosen_time in_partnership partnership_time]
  end
end
