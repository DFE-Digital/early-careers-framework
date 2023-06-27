# frozen_string_literal: true

require "rails_helper"

RSpec.describe "API ECF Unfunded Mentors", type: :request do
  let(:cpd_lead_provider) { create(:cpd_lead_provider, :with_lead_provider) }
  let(:lead_provider) { cpd_lead_provider.lead_provider }
  let(:cohort) { Cohort.current || create(:cohort, :current) }
  let(:partnership) { create(:partnership, lead_provider:, cohort:) }
  let(:induction_programme) { create(:induction_programme, :fip, partnership:) }
  let!(:mentor_profile) { create(:mentor, lead_provider: cpd_lead_provider.lead_provider) }
  let!(:induction_record) { create(:induction_record, induction_programme:, mentor_profile:) }
  let!(:unfunded_mentor_profile) { create(:mentor, :eligible_for_funding) }
  let!(:unfunded_mentor_induction_record) { create(:induction_record, induction_programme:, mentor_profile: unfunded_mentor_profile) }
  let(:unfunded_mentor_profile_user_id) { unfunded_mentor_profile.user.id }

  let(:token) { LeadProviderApiToken.create_with_random_token!(cpd_lead_provider:) }
  let(:bearer_token) { "Bearer #{token}" }
  let(:parsed_response) { JSON.parse(response.body) }

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
        expect(parsed_response["data"][0]["id"]).to eq(unfunded_mentor_profile_user_id)
      end

      describe "ordering" do
        let!(:another_unfunded_mentor_profile) { create(:mentor, :eligible_for_funding) }
        let!(:another_unfunded_mentor_induction_record) { create(:induction_record, induction_programme:, mentor_profile: another_unfunded_mentor_profile) }

        context "when ordering by updated_at ascending" do
          let(:sort_param) { "updated_at" }

          before { get "/api/v3/unfunded-mentors/ecf", params: { sort: sort_param } }

          it "returns an ordered list of unfunded mentors" do
            expect(parsed_response["data"].size).to eql(2)
            expect(parsed_response.dig("data", 0, "attributes", "full_name")).to eql(unfunded_mentor_profile.user.full_name)
            expect(parsed_response.dig("data", 1, "attributes", "full_name")).to eql(another_unfunded_mentor_profile.user.full_name)
          end
        end

        context "when ordering by updated_at descending" do
          let(:sort_param) { "-updated_at" }

          before { get "/api/v3/unfunded-mentors/ecf", params: { sort: sort_param } }

          it "returns an ordered list of unfunded mentors" do
            expect(parsed_response["data"].size).to eql(2)
            expect(parsed_response.dig("data", 0, "attributes", "full_name")).to eql(another_unfunded_mentor_profile.user.full_name)
            expect(parsed_response.dig("data", 1, "attributes", "full_name")).to eql(unfunded_mentor_profile.user.full_name)
          end
        end

        context "when not including sort in the params" do
          before do
            another_unfunded_mentor_profile.user.update!(created_at: 10.days.ago)

            get "/api/v3/unfunded-mentors/ecf", params: { sort: "" }
          end

          it "returns all records ordered by users created_at" do
            expect(parsed_response["data"].size).to eql(2)
            expect(parsed_response.dig("data", 0, "attributes", "full_name")).to eql(another_unfunded_mentor_profile.user.full_name)
            expect(parsed_response.dig("data", 1, "attributes", "full_name")).to eql(unfunded_mentor_profile.user.full_name)
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
        get "/api/v3/unfunded-mentors/ecf/#{unfunded_mentor_profile_user_id}"
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
        expect(parsed_response["data"]["id"]).to eq(unfunded_mentor_profile_user_id)
      end

      context "when user id is incorrect", exceptions_app: true do
        let(:unfunded_mentor_profile_user_id) { "incorrect-id" }

        it "returns 404" do
          expect(response.status).to eq 404
        end
      end
    end

    context "when unauthorized" do
      it "returns 401 for invalid bearer token" do
        default_headers[:Authorization] = "Bearer ugLPicDrpGZdD_w7hhCL"
        get "/api/v3/unfunded-mentors/ecf/#{unfunded_mentor_profile_user_id}"

        expect(response.status).to eq(401)
      end
    end

    context "when using a engage and learn token" do
      let(:token) { EngageAndLearnApiToken.create_with_random_token! }

      it "returns 403 for invalid bearer token" do
        default_headers[:Authorization] = bearer_token
        get "/api/v3/unfunded-mentors/ecf/#{unfunded_mentor_profile_user_id}"

        expect(response.status).to eq(403)
      end
    end
  end
end
