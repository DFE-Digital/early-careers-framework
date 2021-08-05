# frozen_string_literal: true

require "rails_helper"
require "csv"

RSpec.describe "Participants API", type: :request, with_feature_flags: { participant_data_api: "active" } do
  describe "GET /api/v1/participants" do
    let(:cpd_lead_provider) { create(:cpd_lead_provider, lead_provider: lead_provider) }
    let(:lead_provider) { create(:lead_provider) }
    let(:partnership) { create(:partnership, lead_provider: lead_provider) }
    let(:school_cohort) { create(:school_cohort, school: partnership.school, cohort: partnership.cohort, induction_programme_choice: "full_induction_programme") }
    let(:token) { LeadProviderApiToken.create_with_random_token!(cpd_lead_provider: cpd_lead_provider) }
    let(:bearer_token) { "Bearer #{token}" }

    before :each do
      mentor_profile = create(:participant_profile, :mentor, school: partnership.school, cohort: partnership.cohort)
      create_list :participant_profile, 2, :ect, mentor_profile: mentor_profile, school_cohort: school_cohort
      ect_teacher_profile_with_one_active_and_one_withdrawn_profile = ParticipantProfile::ECT.first.teacher_profile
      create(:participant_profile,
             :withdrawn,
             :ect,
             teacher_profile: ect_teacher_profile_with_one_active_and_one_withdrawn_profile,
             school_cohort: school_cohort)
    end
    let!(:withdrawn_ect_profile) { create(:participant_profile, :withdrawn, :ect, school_cohort: school_cohort) }

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
          expect(parsed_response["data"].size).to eql(4)
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
          expect(parsed_response["data"][0])
            .to(have_jsonapi_attributes(
              :email,
              :full_name,
              :mentor_id,
              :school_urn,
              :participant_type,
              :cohort,
              :status,
              :teacher_reference_number,
              :teacher_reference_number_validated,
            ).exactly)
        end

        it "returns correct user types" do
          get "/api/v1/participants"
          mentors = 0
          ects = 0
          withdrawn = 0

          parsed_response["data"].each do |user|
            user_type = user["attributes"]["participant_type"]
            status = user["attributes"]["status"]
            if user_type == "mentor"
              mentors += 1
            elsif user_type == "ect"
              ects += 1
            elsif user_type.nil? && status == "withdrawn"
              withdrawn += 1
            end
          end

          expect(mentors).to eql(1)
          expect(ects).to eql(2)
          expect(withdrawn).to eql(1)
        end

        it "returns the right number of users per page" do
          get "/api/v1/participants", params: { page: { per_page: 2, page: 1 } }
          expect(parsed_response["data"].size).to eql(2)
        end

        it "returns different users for each page" do
          get "/api/v1/participants", params: { page: { per_page: 2, page: 1 } }
          expect(parsed_response["data"].size).to eql(2)
          first_page_id = parsed_response["data"].first["id"]

          get "/api/v1/participants", params: { page: { per_page: 2, page: 2 } }
          second_parsed_response = JSON.parse(response.body)
          second_page_ids = second_parsed_response["data"].map { |item| item["id"] }
          expect(second_parsed_response["data"].size).to eql(2)
          expect(second_page_ids).not_to include first_page_id
        end

        it "returns users changed since a particular time, if given a updated_since parameter" do
          User.first.update!(updated_at: 2.days.ago)
          get "/api/v1/participants", params: { filter: { updated_since: 1.day.ago.iso8601 } }
          expect(parsed_response["data"].size).to eql(3)
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
          expect(parsed_response.length).to eql 4
        end

        it "returns the correct headers" do
          expect(parsed_response.headers).to match_array(%w[id email full_name mentor_id school_urn participant_type cohort status teacher_reference_number teacher_reference_number_validated])
        end

        it "returns the correct values" do
          mentor = ParticipantProfile::Mentor.first.user
          mentor_row = parsed_response.find { |row| row["id"] == mentor.id }
          expect(mentor_row).not_to be_nil
          expect(mentor_row["email"]).to eql mentor.email
          expect(mentor_row["full_name"]).to eql mentor.full_name
          expect(mentor_row["mentor_id"]).to eql ""
          expect(mentor_row["school_urn"]).to eql partnership.school.urn
          expect(mentor_row["participant_type"]).to eql "mentor"
          expect(mentor_row["cohort"]).to eql partnership.cohort.start_year.to_s
          expect(mentor_row["teacher_reference_number"]).to eql mentor.teacher_profile.trn
          expect(mentor_row["teacher_reference_number_validated"]).to eql "true"

          ect = ParticipantProfile::ECT.active.first.user
          ect_row = parsed_response.find { |row| row["id"] == ect.id }
          expect(ect_row).not_to be_nil
          expect(ect_row["email"]).to eql ect.email
          expect(ect_row["full_name"]).to eql ect.full_name
          expect(ect_row["mentor_id"]).to eql mentor.id
          expect(ect_row["school_urn"]).to eql partnership.school.urn
          expect(ect_row["participant_type"]).to eql "ect"
          expect(ect_row["cohort"]).to eql partnership.cohort.start_year.to_s
          expect(ect_row["teacher_reference_number"]).to eql ect.teacher_profile.trn
          expect(ect_row["teacher_reference_number_validated"]).to eql "true"

          withdrawn_row = parsed_response.find { |row| row["id"] == withdrawn_ect_profile.user.id }
          expect(withdrawn_row).not_to be_nil
          expect(withdrawn_row["email"]).to be_empty
          expect(withdrawn_row["full_name"]).to be_empty
          expect(withdrawn_row["mentor_id"]).to be_empty
          expect(withdrawn_row["school_urn"]).to be_empty
          expect(withdrawn_row["participant_type"]).to be_empty
          expect(withdrawn_row["cohort"]).to be_empty
          expect(withdrawn_row["teacher_reference_number"]).to be_empty
          expect(withdrawn_row["teacher_reference_number_validated"]).to be_empty
        end

        it "ignores pagination parameters" do
          get "/api/v1/participants.csv", params: { page: { per_page: 2, page: 1 } }
          expect(parsed_response.length).to eql 4
        end

        it "respects the updated_since parameter" do
          User.first.update!(updated_at: 2.days.ago)
          get "/api/v1/participants.csv", params: { filter: { updated_since: 1.day.ago.iso8601 } }
          expect(parsed_response.length).to eql(3)
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

    context "when using LeadProviderApiToken with only NPQ access" do
      let(:cpd_lead_provider) { create(:cpd_lead_provider, npq_lead_provider: npq_lead_provider, lead_provider: nil) }
      let(:npq_lead_provider) { create(:npq_lead_provider) }
      let(:token) { LeadProviderApiToken.create_with_random_token!(cpd_lead_provider: cpd_lead_provider) }

      it "returns 403" do
        default_headers[:Authorization] = bearer_token
        get "/api/v1/participants"
        expect(response.status).to eq 403
      end
    end
  end
end
