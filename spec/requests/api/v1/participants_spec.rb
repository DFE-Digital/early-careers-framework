# frozen_string_literal: true

require "rails_helper"
require "csv"

RSpec.describe "Participants API", :with_default_schedules, type: :request do
  describe "GET /api/v1/participants" do
    let(:cpd_lead_provider) { create(:cpd_lead_provider, :with_lead_provider) }
    let(:lead_provider)     { cpd_lead_provider.lead_provider }
    let(:school_cohort)     { create(:school_cohort, :fip, :with_induction_programme, lead_provider:) }
    let(:token)             { LeadProviderApiToken.create_with_random_token!(cpd_lead_provider:) }
    let(:bearer_token)      { "Bearer #{token}" }

    let!(:mentor_profile) do
      travel_to 4.days.ago do
        create(:mentor, school_cohort:, lead_provider:)
      end
    end

    before :each do
      travel_to 3.days.ago do
        create :ect, :eligible_for_funding, mentor_profile_id: mentor_profile.id, school_cohort:
      end
      travel_to 3.days.ago + 1.minute do
        create :ect, :eligible_for_funding, mentor_profile_id: mentor_profile.id, school_cohort:
      end

      ect_teacher_profile_with_one_active_and_one_withdrawn_profile_record = ParticipantProfile::ECT.first
      create(:ect, :withdrawn_record, user: ect_teacher_profile_with_one_active_and_one_withdrawn_profile_record.user, school_cohort:)
    end

    let!(:withdrawn_ect_profile_record) do
      create(:ect, :eligible_for_funding, :withdrawn_record, school_cohort:)
    end

    let(:user) { create(:user) }

    let(:early_career_teacher_profile) do
      create(:ect, school_cohort:, user:)
    end

    context "when authorized" do
      before do
        default_headers[:Authorization] = bearer_token
      end

      describe "JSON Index API" do
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
              :eligible_for_funding,
              :pupil_premium_uplift,
              :sparsity_uplift,
              :training_status,
              :schedule_identifier,
              :updated_at,
            ).exactly)
        end

        it "returns correct user types" do
          get "/api/v1/participants"

          mentors = parsed_response["data"].count { |h| h["attributes"]["participant_type"] == "mentor" }
          withdrawn = parsed_response["data"].count { |h| h["attributes"]["status"] == "withdrawn" }
          ects = parsed_response["data"].count { |h| h["attributes"]["participant_type"] == "ect" }

          expect(mentors).to eql(1)
          expect(ects).to eql(3)
          expect(withdrawn).to eql(2)
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

        it "returns users in a consistent order" do
          get "/api/v1/participants"

          expect(parsed_response["data"].first["id"]).to eq User.order(created_at: :asc).first.id
          expect(parsed_response["data"].last["id"]).to eq User.order(created_at: :asc).last.id
        end

        context "when updated_since parameter is supplied" do
          it "returns users changed since the updated_since parameter" do
            get "/api/v1/participants", params: { filter: { updated_since: 1.day.ago.iso8601 } }
            expect(parsed_response["data"].size).to eql(2)
          end

          it "returns users changed since the updated_since parameter with other formats" do
            User.order(created_at: :asc).first.update!(updated_at: Date.new(1970, 1, 1))
            get "/api/v1/participants", params: { filter: { updated_since: "1980-01-01T00%3A00%3A00%2B01%3A00" } }
            expect(parsed_response["data"].size).to eq(3)
          end

          context "when updated_since parameter is encoded/escaped" do
            it "unescapes the value and returns users changed since the updated_since date" do
              since = URI.encode_www_form_component(1.day.ago.iso8601)
              get "/api/v1/participants", params: { filter: { updated_since: since } }
              expect(parsed_response["data"].size).to eql(2)
            end
          end

          context "when updated_since in an invalid format" do
            it "returns a 400 status" do
              get "/api/v1/participants", params: { filter: { updated_since: "23rm21" } }
              expect(response.status).to eq 400
            end
          end
        end
      end

      describe "CSV Index API" do
        let(:parsed_response) { CSV.parse(response.body, headers: true) }
        before do
          get "/api/v1/participants.csv"
        end

        it "returns the correct CSV content type header" do
          expect(response.headers["Content-Type"]).to eql("text/csv")
        end

        it "returns all users" do
          expect(parsed_response.length).to eql(4)
        end

        it "returns the correct headers" do
          expect(parsed_response.headers).to match_array(
            %w[id
               email
               full_name
               mentor_id
               school_urn
               participant_type
               cohort
               status
               teacher_reference_number
               teacher_reference_number_validated
               eligible_for_funding
               pupil_premium_uplift
               sparsity_uplift
               training_status
               schedule_identifier
               updated_at],
          )
        end

        it "returns the correct values" do
          mentor = ParticipantProfile::Mentor.first.user
          mentor_row = parsed_response.find { |row| row["id"] == mentor.id }
          expect(mentor_row).not_to be_nil
          expect(mentor_row["email"]).to eql mentor.email
          expect(mentor_row["full_name"]).to eql mentor.full_name
          expect(mentor_row["mentor_id"]).to eql ""
          expect(mentor_row["school_urn"]).to eql mentor.participant_profiles[0].induction_records[0].school_cohort.school.urn
          expect(mentor_row["participant_type"]).to eql "mentor"
          expect(mentor_row["cohort"]).to eql mentor.participant_profiles[0].current_induction_record.cohort.start_year.to_s
          expect(mentor_row["teacher_reference_number"]).to be_empty
          expect(mentor_row["teacher_reference_number_validated"]).to be_empty
          expect(mentor_row["eligible_for_funding"]).to be_empty
          expect(mentor_row["pupil_premium_uplift"]).to eql "false"
          expect(mentor_row["sparsity_uplift"]).to eql "false"
          expect(mentor_row["training_status"]).to eql "active"

          ect = InductionRecord
                  .joins(:participant_profile)
                  .where(participant_profile: { type: "ParticipantProfile::ECT" })
                  .order(created_at: :asc)
                  .last
                  .participant_profile
                  .user
          ect_row = parsed_response.find { |row| row["id"] == ect.id }
          expect(ect_row).not_to be_nil
          expect(ect_row["email"]).to eql ect.email
          expect(ect_row["full_name"]).to eql ect.full_name
          expect(ect_row["mentor_id"]).to be_blank
          expect(ect_row["school_urn"]).to eql ect.participant_profiles[0].induction_records.latest.school_cohort.school.urn
          expect(ect_row["participant_type"]).to eql "ect"
          expect(ect_row["cohort"]).to eql ect.participant_profiles[0].induction_records.latest.cohort.start_year.to_s
          expect(ect_row["teacher_reference_number"]).to eql ect.teacher_profile.trn
          expect(ect_row["teacher_reference_number_validated"]).to eql "true"
          expect(ect_row["eligible_for_funding"]).to eq "true"
          expect(ect_row["pupil_premium_uplift"]).to eql "false"
          expect(ect_row["sparsity_uplift"]).to eql "false"
          expect(ect_row["training_status"]).to eql "active"

          withdrawn_record_row = parsed_response.find { |row| row["id"] == withdrawn_ect_profile_record.user.id }
          expect(withdrawn_record_row).not_to be_nil
          expect(withdrawn_record_row["email"]).to eql(withdrawn_ect_profile_record.user.email)
          expect(withdrawn_record_row["full_name"]).to eql(withdrawn_ect_profile_record.user.full_name)
          expect(withdrawn_record_row["mentor_id"]).to be_empty
          expect(withdrawn_record_row["school_urn"]).to eql withdrawn_ect_profile_record.induction_records[0].school_cohort.school.urn
          expect(withdrawn_record_row["participant_type"]).to eql(withdrawn_ect_profile_record.participant_type.to_s)
          expect(withdrawn_record_row["cohort"]).to eql(withdrawn_ect_profile_record.cohort.start_year.to_s)
          expect(withdrawn_record_row["teacher_reference_number"]).to eql(withdrawn_ect_profile_record.teacher_profile.trn)
          expect(withdrawn_record_row["teacher_reference_number_validated"]).to eq "true"
          expect(withdrawn_record_row["eligible_for_funding"]).to eq "true"
          expect(withdrawn_record_row["pupil_premium_uplift"]).to eql(withdrawn_ect_profile_record.pupil_premium_uplift.to_s)
          expect(withdrawn_record_row["sparsity_uplift"]).to eql(withdrawn_ect_profile_record.sparsity_uplift.to_s)
          expect(withdrawn_record_row["training_status"]).to eql(withdrawn_ect_profile_record.induction_records.first.training_status)
        end

        it "ignores pagination parameters" do
          get "/api/v1/participants.csv", params: { page: { per_page: 2, page: 1 } }
          expect(parsed_response.length).to eql(4)
        end

        it "respects the updated_since parameter" do
          get "/api/v1/participants.csv", params: { filter: { updated_since: 1.day.ago.iso8601 } }
          expect(parsed_response.length).to eql(2)
        end
      end

      describe "JSON Participant Withdrawal" do
        it_behaves_like "a participant withdraw action endpoint" do
          let(:url) { "/api/v1/participants/#{early_career_teacher_profile.user.id}/withdraw" }
          let(:params) { { data: { attributes: { course_identifier: "ecf-induction", reason: "moved-school" } } } }

          it "changes the training status of a participant to withdrawn" do
            put url, params: params

            expect(response).to be_successful
            expect(parsed_response.dig("data", "attributes", "training_status")).to eql("withdrawn")
          end
        end
      end

      it_behaves_like "JSON Participant Change schedule endpoint"

      it_behaves_like "JSON Participant Deferral endpoint", "participant" do
        let(:url)               { "/api/v1/participants/#{early_career_teacher_profile.user.id}/defer" }
        let(:withdrawal_url)    { "/api/v1/participants/#{early_career_teacher_profile.user.id}/withdraw" }
        let(:params)            { { data: { attributes: { course_identifier: "ecf-induction", reason: "career-break" } } } }
        let(:withdrawal_params) { { data: { attributes: { course_identifier: "ecf-induction", reason: "left-teaching-profession" } } } }
      end

      it_behaves_like "JSON Participant Resume endpoint", "participant" do
        let(:url)               { "/api/v1/participants/#{early_career_teacher_profile.user.id}/resume" }
        let(:withdrawal_url)    { "/api/v1/participants/#{early_career_teacher_profile.user.id}/withdraw" }
        let(:params)            { { data: { attributes: { course_identifier: "ecf-induction" } } } }
        let(:withdrawal_params) { { data: { attributes: { course_identifier: "ecf-induction", reason: "left-teaching-profession" } } } }

        before do
          put "/api/v1/participants/#{early_career_teacher_profile.user.id}/defer",
              params: { data: { attributes: { course_identifier: "ecf-induction", reason: "career-break" } } }
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
      let(:cpd_lead_provider) { create(:cpd_lead_provider, npq_lead_provider:, lead_provider: nil) }
      let(:npq_lead_provider) { create(:npq_lead_provider) }
      let(:token) { LeadProviderApiToken.create_with_random_token!(cpd_lead_provider:) }

      it "returns 403" do
        default_headers[:Authorization] = bearer_token
        get "/api/v1/participants"
        expect(response.status).to eq 403
      end
    end
  end
end
