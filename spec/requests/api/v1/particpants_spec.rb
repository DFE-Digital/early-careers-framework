# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Participants API", type: :request, with_feature_flags: { participant_data_api: "active" } do
  describe "GET /api/v1/participants" do
    let(:lead_provider) { create(:lead_provider) }
    let(:partnership) { create(:partnership, lead_provider: lead_provider) }
    let(:token) { LeadProviderApiToken.create_with_random_token!(lead_provider: lead_provider) }
    let(:bearer_token) { "Bearer #{token}" }

    let(:parsed_response) { JSON.parse(response.body) }

    before :each do
      mentor = create(:user, :mentor, school: partnership.school)
      2.times do
        create(:user, :early_career_teacher, mentor: mentor, school: partnership.school)
      end
    end

    context "when authorized" do
      before do
        default_headers[:Authorization] = bearer_token
      end

      describe "JSON API" do
        it "returns correct jsonapi content type header" do
          get "/api/v1/participants"
          expect(response.headers["Content-Type"]).to eql("application/vnd.api+json")
        end

        it "returns all users" do
          get "/api/v1/participants"
          expect(parsed_response["data"].size).to eql(3)
        end

        it "returns correct type" do
          get "/api/v1/participants"
          expect(parsed_response["data"][0]).to have_type("participant")
        end

        it "returns IDs" do
          get "/api/v1/participants"
          expect(parsed_response["data"][0]["id"]).to be_in(User.pluck(:id))
        end

        it "has correct attributes" do
          get "/api/v1/participants"
          expect(parsed_response["data"][0]).to have_jsonapi_attributes(:email, :full_name, :mentor_id, :school_urn, :participant_type, :cohort).exactly
        end

        it "returns correct user types" do
          get "/api/v1/participants"
          mentors = 0
          ects = 0

          parsed_response["data"].each do |user|
            user_type = user["attributes"]["participant_type"]
            if user_type == "mentor"
              mentors += 1
            elsif user_type == "ect"
              ects += 1
            end
          end

          expect(mentors).to eql(1)
          expect(ects).to eql(2)
        end

        it "returns the right number of users per page" do
          get "/api/v1/participants", params: { page: { per_page: 2, page: 1 } }
          expect(parsed_response["data"].size).to eql(2)
        end

        it "returns different users for each page" do
          get "/api/v1/participants", params: { page: { per_page: 2, page: 1 } }
          expect(parsed_response["data"].size).to eql(2)

          get "/api/v1/participants", params: { page: { per_page: 2, page: 2 } }
          expect(JSON.parse(response.body)["data"].size).to eql(1)
        end

        it "returns users changed since a particular time, if given a changed_since parameter" do
          User.first.update!(updated_at: 2.days.ago)
          get "/api/v1/participants", params: { filter: { updated_since: 1.day.ago.iso8601 } }
          expect(parsed_response["data"].size).to eql(2)
        end
      end
    end

    context "when unauthorized" do
      it "returns 401 for invalid bearer token" do
        default_headers[:Authorization] = "Bearer ugLPicDrpGZdD_w7hhCL"
        get "/api/v1/participants"
        expect(response.status).to eq 401
      end
    end

    context "when using a engage and learn token" do
      let(:token) { EngageAndLearnApiToken.create_with_random_token! }

      it "returns 401 for invalid bearer token" do
        default_headers[:Authorization] = bearer_token
        get "/api/v1/participants"
        expect(response.status).to eq 403
      end
    end
  end
end
