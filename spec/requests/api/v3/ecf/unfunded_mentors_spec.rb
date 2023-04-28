# frozen_string_literal: true

require "rails_helper"

RSpec.describe "API ECF Unfunded Mentors", :with_default_schedules, type: :request, with_feature_flags: { api_v3: "active" } do
  let(:cpd_lead_provider) { create(:cpd_lead_provider, :with_lead_provider) }
  let(:token) { LeadProviderApiToken.create_with_random_token!(cpd_lead_provider:) }
  let(:bearer_token) { "Bearer #{token}" }
  let(:parsed_response) { JSON.parse(response.body) }

  let!(:mentor_profile) { create(:mentor, :eligible_for_funding) }
  let!(:mentor_profile_user_id) { mentor_profile.user.id }
  let!(:another_mentor_profile) { create(:mentor, :eligible_for_funding, lead_provider: cpd_lead_provider.lead_provider) }

  describe "#index" do
    context "when authorized" do
      before do
        default_headers[:Authorization] = bearer_token
      end

      it "returns correct JSON API content type header" do
        get "/api/v3/unfunded-mentors/ecf"

        expect(response.headers["Content-Type"]).to eq("application/vnd.api+json")
      end

      it "returns correct type" do
        get "/api/v3/unfunded-mentors/ecf"

        expect(parsed_response["data"][0]).to have_type("unfunded-mentor")
      end

      it "has correct attributes" do
        get "/api/v3/unfunded-mentors/ecf"

        expect(parsed_response["data"][0]).to have_jsonapi_attributes(
          :full_name,
          :email,
          :teacher_reference_number,
          :created_at,
          :updated_at,
        ).exactly
      end

      it "returns only those mentors not being trained by the lead provider calling the endpoint" do
        get "/api/v3/unfunded-mentors/ecf"

        expect(parsed_response["data"].size).to eql(1)
        expect(parsed_response["data"][0]["id"]).to eq(mentor_profile_user_id)
      end

      describe "ordering" do
        let!(:another_mentor_profile) { create(:mentor, :eligible_for_funding) }

        before { get "/api/v3/unfunded-mentors/ecf", params: { sort: sort_param } }

        context "when ordering by updated_at ascending" do
          let(:sort_param) { "updated_at" }

          it "returns an ordered list of unfunded mentors" do
            expect(parsed_response["data"].size).to eql(2)
            expect(parsed_response.dig("data", 0, "attributes", "full_name")).to eql(mentor_profile.user.full_name)
            expect(parsed_response.dig("data", 1, "attributes", "full_name")).to eql(another_mentor_profile.user.full_name)
          end
        end

        context "when ordering by updated_at descending" do
          let(:sort_param) { "-updated_at" }

          it "returns an ordered list of unfunded mentors" do
            expect(parsed_response["data"].size).to eql(2)
            expect(parsed_response.dig("data", 0, "attributes", "full_name")).to eql(another_mentor_profile.user.full_name)
            expect(parsed_response.dig("data", 1, "attributes", "full_name")).to eql(mentor_profile.user.full_name)
          end
        end
      end

      context "when filtering by updated_since" do
        before do
          travel_to 10.days.ago do
            create_list(:mentor, 3, :eligible_for_funding)
          end
        end

        it "returns content updated after specified timestamp" do
          get "/api/v3/unfunded-mentors/ecf", params: { filter: { updated_since: 2.days.ago.iso8601 } }

          expect(parsed_response["data"].size).to eq(1)
        end

        context "with invalid filter of a string" do
          it "returns an error" do
            get "/api/v3/unfunded-mentors/ecf", params: { filter: 2.days.ago.iso8601 }
            expect(response).to be_bad_request
            expect(parsed_response).to eql(HashWithIndifferentAccess.new({
              "errors": [
                {
                  "title": "Bad parameter",
                  "detail": "Filter must be a hash",
                },
              ],
            }))
          end
        end
      end
    end

    context "when unauthorized" do
      it "returns 401 for invalid bearer token" do
        default_headers[:Authorization] = "Bearer ugLPicDrpGZdD_w7hhCL"
        get "/api/v3/unfunded-mentors/ecf"

        expect(response.status).to eq(401)
      end
    end

    context "when using a engage and learn token" do
      let(:token) { EngageAndLearnApiToken.create_with_random_token! }

      it "returns 403 for invalid bearer token" do
        default_headers[:Authorization] = bearer_token
        get "/api/v3/unfunded-mentors/ecf"

        expect(response.status).to eq(403)
      end
    end
  end

  describe "#show" do
    context "when authorized" do
      before do
        default_headers[:Authorization] = bearer_token
        get "/api/v3/unfunded-mentors/ecf/#{mentor_profile_user_id}"
      end

      it "returns correct JSON API content type header" do
        expect(response.headers["Content-Type"]).to eq("application/vnd.api+json")
      end

      it "returns correct type" do
        expect(parsed_response["data"]).to have_type("unfunded-mentor")
      end

      it "has correct attributes" do
        expect(parsed_response["data"]).to have_jsonapi_attributes(
          :full_name,
          :email,
          :teacher_reference_number,
          :created_at,
          :updated_at,
        ).exactly
      end

      it "returns unfunded mentor with the corresponding id" do
        expect(parsed_response["data"]["id"]).to eq(mentor_profile_user_id)
      end

      context "when user id is incorrect", exceptions_app: true do
        let(:mentor_profile_user_id) { "incorrect-id" }

        it "returns 404" do
          expect(response.status).to eq 404
        end

        it "returns an error message" do
          expect(parsed_response["errors"][0]["title"]).to eq("The requested resource was not found")
        end
      end
    end

    context "when unauthorized" do
      it "returns 401 for invalid bearer token" do
        default_headers[:Authorization] = "Bearer ugLPicDrpGZdD_w7hhCL"
        get "/api/v3/unfunded-mentors/ecf/#{mentor_profile.user.id}"

        expect(response.status).to eq(401)
      end
    end

    context "when using a engage and learn token" do
      let(:token) { EngageAndLearnApiToken.create_with_random_token! }

      it "returns 403 for invalid bearer token" do
        default_headers[:Authorization] = bearer_token
        get "/api/v3/unfunded-mentors/ecf/#{mentor_profile.user.id}"

        expect(response.status).to eq(403)
      end
    end
  end
end
