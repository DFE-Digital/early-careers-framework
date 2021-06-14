# frozen_string_literal: true

require "rails_helper"

RSpec.describe "API Users", type: :request do
  describe "#index" do
    let(:token) { EngageAndLearnApiToken.create_with_random_token! }
    let(:bearer_token) { "Bearer #{token}" }

    let(:parsed_response) { JSON.parse(response.body) }

    before :each do
      # Heads up, for some reason the stored CIP IDs don't match
      cip = create(:core_induction_programme, name: "Teach First")
      cohort = create(:cohort)
      school = create(:school)
      create(:school_cohort, school: school, cohort: cohort)
      mentor = create(:user, :mentor)
      mentor.mentor_profile.update!(core_induction_programme: cip)
      mentor.mentor_profile.update!(school: school)
      2.times do
        ect = create(:user, :early_career_teacher)
        ect.early_career_teacher_profile.update!(core_induction_programme: cip)
        ect.early_career_teacher_profile.update!(school: school)
      end
    end

    context "when authorized" do
      before do
        default_headers[:Authorization] = bearer_token
      end

      it "returns correct jsonapi content type header" do
        get "/api/v1/users"
        expect(response.headers["Content-Type"]).to eql("application/vnd.api+json")
      end

      it "returns all users" do
        get "/api/v1/users"
        expect(parsed_response["data"].size).to eql(3)
      end

      it "returns correct type" do
        get "/api/v1/users"
        expect(parsed_response["data"][0]).to have_type("user")
      end

      it "returns IDs" do
        get "/api/v1/users"
        expect(parsed_response["data"][0]["id"]).to be_in(User.pluck(:id))
      end

      it "has correct attributes" do
        get "/api/v1/users"
        expect(parsed_response["data"][0]).to have_jsonapi_attributes(:email, :full_name, :user_type, :core_induction_programme, :induction_programme_choice).exactly
      end

      it "returns correct user types" do
        get "/api/v1/users"
        mentors = 0
        ects = 0

        parsed_response["data"].each do |user|
          user_type = user["attributes"]["user_type"]
          if user_type == "mentor"
            mentors += 1
          elsif user_type == "early_career_teacher"
            ects += 1
          end
        end

        expect(mentors).to eql(1)
        expect(ects).to eql(2)
      end

      it "returns correct CIPs" do
        get "/api/v1/users"
        expect(parsed_response["data"][0]["attributes"]["core_induction_programme"]).to eql("teach_first")
        expect(parsed_response["data"][1]["attributes"]["core_induction_programme"]).to eql("teach_first")
      end

      it "returns the right number of users per page" do
        get "/api/v1/users", params: { page: { per_page: 2, page: 1 } }
        expect(parsed_response["data"].size).to eql(2)
      end

      it "returns different users for each page" do
        get "/api/v1/users", params: { page: { per_page: 2, page: 1 } }
        expect(parsed_response["data"].size).to eql(2)

        get "/api/v1/users", params: { page: { per_page: 2, page: 2 } }
        expect(JSON.parse(response.body)["data"].size).to eql(1)
      end

      it "returns users changed since a particular time, if given a changed_since parameter" do
        User.first.update!(updated_at: 2.days.ago)
        get "/api/v1/users", params: { filter: { updated_since: 1.day.ago.iso8601 } }
        expect(parsed_response["data"].size).to eql(2)
      end
    end

    context "when unauthorized" do
      it "returns 401 for invalid bearer token" do
        default_headers[:Authorization] = "Bearer ugLPicDrpGZdD_w7hhCL"
        get "/api/v1/users"
        expect(response.status).to eq 401
      end
    end
  end
end
