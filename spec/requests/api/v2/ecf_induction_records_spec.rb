# frozen_string_literal: true

require "rails_helper"

RSpec.describe "API Induction Records", :with_default_schedules, type: :request do
  let(:parsed_response) { JSON.parse(response.body) }
  let(:token) { EngageAndLearnApiToken.create_with_random_token! }
  let(:bearer_token) { "Bearer #{token}" }

  describe "#index" do
    # Heads up, for some reason the stored CIP IDs don't match
    let(:core_induction_programme) { create(:core_induction_programme, name: "Teach First") }
    let(:induction_programme) do
      induction_programme = create(:induction_programme, :cip)
      induction_programme.update!(core_induction_programme:)
      induction_programme
    end
    let(:school) { create :school }
    let(:cohort) { Cohort.current }
    let(:school_cohort) { create :school_cohort, school: }

    let(:mentor_profile) { create :mentor_participant_profile, school_cohort:, core_induction_programme:, cohort: }
    let(:first_ect_user) { create :user, full_name: "My First ECT", email: "first-ect@example.com" }

    let!(:npq_participant) { create :npq_participant_profile, school: }
    let!(:npq_mentor_participant) { create :npq_participant_profile, school:, teacher_profile: mentor_profile.teacher_profile }
    let!(:first_ecf_participant) { create :ect_participant_profile, user: first_ect_user, school_cohort:, core_induction_programme:, cohort: }
    let!(:second_ecf_participant) { create :ect_participant_profile, school_cohort:, core_induction_programme:, cohort: }

    before do
      Induction::Enrol.call(participant_profile: mentor_profile, induction_programme:, start_date: 2.months.ago)
      Induction::Enrol.call(participant_profile: first_ecf_participant, induction_programme:, start_date: 2.months.ago)
      Induction::Enrol.call(participant_profile: second_ecf_participant, induction_programme:, start_date: 2.months.ago)
    end

    context "when authorized" do
      before do
        default_headers[:Authorization] = bearer_token
      end

      it "returns correct jsonapi content type header" do
        get "/api/v2/ecf-induction-records"
        expect(response.headers["Content-Type"]).to eql("application/vnd.api+json")
      end

      it "returns all users" do
        get "/api/v2/ecf-induction-records"
        expect(parsed_response["data"].size).to eql(3)
      end

      it "returns correct type" do
        get "/api/v2/ecf-induction-records"
        expect(parsed_response["data"][0]).to have_type("user")
      end

      it "returns IDs" do
        get "/api/v2/ecf-induction-records"
        expect(parsed_response["data"][0]["id"]).to be_in(User.pluck(:id))
      end

      it "has correct attributes" do
        get "/api/v2/ecf-induction-records"
        expect(parsed_response["data"][0]).to have_jsonapi_attributes(:email, :full_name, :user_type, :core_induction_programme, :induction_programme_choice, :registration_completed, :cohort).exactly
      end

      it "returns correct user types" do
        get "/api/v2/ecf-induction-records"

        mentors = parsed_response["data"].count { |hash| hash["attributes"]["user_type"] == "mentor" }
        ects = parsed_response["data"].count { |hash| hash["attributes"]["user_type"] == "early_career_teacher" }
        others = parsed_response["data"].count { |hash| hash["attributes"]["user_type"] == "other" }

        expect(mentors).to eql(1)
        expect(ects).to eql(2)
        expect(others).to eql(0)
      end

      it "returns correct CIPs" do
        get "/api/v2/ecf-induction-records"
        expect(parsed_response["data"][0]["attributes"]["core_induction_programme"]).to eql("teach_first")
        expect(parsed_response["data"][2]["attributes"]["core_induction_programme"]).to eql("teach_first")
      end

      it "should return correct cohort year" do
        get "/api/v2/ecf-induction-records"
        expect(parsed_response["data"][0]["attributes"]["cohort"]).to eql(2021)
      end

      it "returns the right number of users per page" do
        get "/api/v2/ecf-induction-records", params: { page: { per_page: 2, page: 1 } }
        expect(parsed_response["data"].size).to eql(2)
      end

      it "returns different users for first page" do
        get "/api/v2/ecf-induction-records", params: { page: { per_page: 2, page: 1 } }
        expect(parsed_response["data"].size).to eql(2)
      end

      it "returns different users for second page" do
        get "/api/v2/ecf-induction-records", params: { page: { per_page: 2, page: 2 } }
        expect(parsed_response["data"].size).to eql(1)
      end

      it "returns users changed since a particular time, if given a changed_since parameter" do
        first_ecf_participant.current_induction_records.first.update!(updated_at: 2.days.ago)
        get "/api/v2/ecf-induction-records", params: { filter: { updated_since: 1.day.ago.iso8601 } }
        expect(parsed_response["data"].size).to eql(2)
      end

      context "when filtering by email" do
        it "returns users that match" do
          email = first_ect_user.email
          get "/api/v2/ecf-induction-records", params: { filter: { email: } }
          expect(parsed_response["data"].size).to eql(1)
          expect(parsed_response.dig("data", 0, "attributes", "email")).to eql(email)
        end

        it "returns no users if no matches" do
          email = "dontexist@example.com"
          get "/api/v2/ecf-induction-records", params: { filter: { email: } }
          expect(parsed_response["data"].size).to eql(0)
        end
      end
    end

    context "when unauthorized" do
      it "returns 401 for invalid bearer token" do
        default_headers[:Authorization] = "Bearer ugLPicDrpGZdD_w7hhCL"
        get "/api/v2/ecf-induction-records"
        expect(response.status).to eq 401
      end
    end

    context "when using a lead provider token" do
      let(:token) { LeadProviderApiToken.create_with_random_token!(lead_provider: create(:lead_provider)) }

      it "returns 403 for invalid bearer token" do
        default_headers[:Authorization] = bearer_token
        get "/api/v2/ecf-induction-records"
        expect(response.status).to eq 403
      end
    end
  end

  describe "#create" do
    context "when authorized" do
      before do
        default_headers[:Authorization] = bearer_token
        default_headers["Content-Type"] = "application/vnd.api+json"
      end

      let(:json) do
        {
          data: {
            type: "user",
            attributes: {
              full_name: "John Doe",
              email: "john.doe@example.com",
            },
          },
        }.to_json
      end

      it "returns a 201" do
        post "/api/v2/ecf-induction-records.json", params: json
        expect(response).to be_created
      end

      it "returns correct jsonapi content type header" do
        post "/api/v2/ecf-induction-records.json", params: json
        expect(response.headers["Content-Type"]).to eql("application/vnd.api+json")
      end

      it "creates a user record" do
        expect {
          post "/api/v2/ecf-induction-records", params: json
        }.to change(User, :count).by(1)

        user = User.order(:created_at).last

        expect(user.full_name).to eql("John Doe")
        expect(user.email).to eql("john.doe@example.com")
      end

      it "returns the created user resource" do
        post "/api/v2/ecf-induction-records.json", params: json

        user = User.order(:created_at).last

        expect(parsed_response["data"]["type"]).to eql("user")
        expect(parsed_response["data"]["id"]).to eql(user.id)
        expect(parsed_response["data"]["attributes"]["full_name"]).to eql("John Doe")
        expect(parsed_response["data"]["attributes"]["email"]).to eql("john.doe@example.com")
      end

      context "when user with email address already exists" do
        before do
          User.create!(email: "john.doe@example.com", full_name: "John Doeeeeee")
        end

        it "returns a 409" do
          post "/api/v2/ecf-induction-records.json", params: json
          expect(response.code).to eql("409")
        end

        it "does not create another record" do
          expect {
            post "/api/v2/ecf-induction-records", params: json
          }.not_to change(User, :count)
        end
      end
    end
  end
end
