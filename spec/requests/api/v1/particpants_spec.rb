# frozen_string_literal: true

require "rails_helper"
require "csv"

RSpec.describe "Participants API", type: :request, with_feature_flags: { participant_data_api: "active" } do
  describe "GET /api/v1/participants" do
    let(:lead_provider) { create(:lead_provider) }
    let(:partnership) { create(:partnership, lead_provider: lead_provider) }
    let(:token) { LeadProviderApiToken.create_with_random_token!(lead_provider: lead_provider) }
    let(:bearer_token) { "Bearer #{token}" }

    before :each do
      mentor = create(:user, :mentor, school: partnership.school, cohort: partnership.cohort)
      2.times do
        create(:user, :early_career_teacher, mentor: mentor, school: partnership.school, cohort: partnership.cohort)
      end
    end

    context "when authorized" do
      before do
        default_headers[:Authorization] = bearer_token
      end

      describe "JSON API" do
        let(:parsed_response) { JSON.parse(response.body) }

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

        it "returns users changed since a particular time, if given a updated_since parameter" do
          User.first.update!(updated_at: 2.days.ago)
          get "/api/v1/participants", params: { filter: { updated_since: 1.day.ago.iso8601 } }
          expect(parsed_response["data"].size).to eql(2)
        end
      end

      describe "CSV API" do
        let(:parsed_response) { CSV.parse(response.body, headers: true) }
        before do
          get "/api/v1/participants.csv"
        end

        it "returns the correct CSV content type header" do
          expect(response.headers["Content-Type"]).to eql("text/csv")
        end

        it "returns all users" do
          expect(parsed_response.length).to eql 3
        end

        it "returns the correct headers" do
          expect(parsed_response.headers).to match_array(%w[id email full_name mentor_id school_urn participant_type cohort])
        end

        it "returns the correct values" do
          mentor = MentorProfile.first.user
          mentor_row = parsed_response.find { |row| row["id"] == mentor.id }
          expect(mentor_row).not_to be_nil
          expect(mentor_row["email"]).to eql mentor.email
          expect(mentor_row["full_name"]).to eql mentor.full_name
          expect(mentor_row["mentor_id"]).to be_nil
          expect(mentor_row["school_urn"]).to eql partnership.school.urn
          expect(mentor_row["participant_type"]).to eql "mentor"
          expect(mentor_row["cohort"]).to eql partnership.cohort.start_year.to_s

          ect = EarlyCareerTeacherProfile.first.user
          ect_row = parsed_response.find { |row| row["id"] == ect.id }
          expect(ect_row).not_to be_nil
          expect(ect_row["email"]).to eql ect.email
          expect(ect_row["full_name"]).to eql ect.full_name
          expect(ect_row["mentor_id"]).to eql mentor.id
          expect(ect_row["school_urn"]).to eql partnership.school.urn
          expect(ect_row["participant_type"]).to eql "ect"
          expect(ect_row["cohort"]).to eql partnership.cohort.start_year.to_s
        end

        it "ignores pagination parameters" do
          get "/api/v1/participants.csv", params: { page: { per_page: 2, page: 1 } }
          expect(parsed_response.length).to eql 3
        end

        it "respects the updated_since parameter" do
          User.first.update!(updated_at: 2.days.ago)
          get "/api/v1/participants.csv", params: { filter: { updated_since: 1.day.ago.iso8601 } }
          expect(parsed_response.length).to eql(2)
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
