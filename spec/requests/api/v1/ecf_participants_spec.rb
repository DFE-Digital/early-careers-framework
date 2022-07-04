# frozen_string_literal: true

require "rails_helper"
require "csv"

RSpec.describe "Participants API", type: :request do
  let(:cpd_lead_provider) { create(:cpd_lead_provider, lead_provider:) }
  let(:lead_provider) { create(:lead_provider) }
  let(:cohort) { create(:cohort, :current) }
  let(:partnership) { create(:partnership, lead_provider:, cohort:) }
  let(:induction_programme) { create(:induction_programme, partnership:) }
  let(:school_cohort) { create(:school_cohort, school: partnership.school, cohort:, induction_programme_choice: "full_induction_programme") }
  let(:token) { LeadProviderApiToken.create_with_random_token!(cpd_lead_provider:) }
  let(:bearer_token) { "Bearer #{token}" }
  let!(:mentor_profile) do
    create(:mentor_participant_profile, school_cohort:)
      .tap { |profile| Induction::Enrol.call(participant_profile: profile, induction_programme:) }
  end

  before :each do
    profiles = create_list :ect_participant_profile, 2, mentor_profile: mentor_profile, school_cohort: school_cohort
    profiles.each do |profile|
      Induction::Enrol.call(participant_profile: profile, induction_programme:).tap do |ir|
        ir.update!(mentor_profile:)
      end
    end

    ect_teacher_profile_with_one_active_and_one_withdrawn_profile_record = ParticipantProfile::ECT.first.teacher_profile
    profile = create(
      :ect_participant_profile,
      :withdrawn_record,
      teacher_profile: ect_teacher_profile_with_one_active_and_one_withdrawn_profile_record,
      school_cohort:,
    )
    Induction::Enrol.call(participant_profile: profile, induction_programme:)
      .tap { |induction_record| induction_record.update!(training_status: "withdrawn") }
    default_headers[:Authorization] = bearer_token
  end

  let!(:withdrawn_ect_profile_record) do
    create(:ect_participant_profile, :withdrawn_record, school_cohort:)
      .tap do |profile|
        Induction::Enrol.call(participant_profile: profile, induction_programme:)
          .tap { |induction_record| induction_record.update!(training_status: "withdrawn", induction_status: "withdrawn") }
      end
  end

  let(:user) { create(:user) }

  let(:early_career_teacher_profile) do
    create(:ect_participant_profile, school_cohort:, user:)
      .tap { |profile| Induction::Enrol.call(participant_profile: profile, induction_programme:) }
  end

  describe "GET /api/v1/participants/ecf" do
    context "when authorized" do
      before do
        default_headers[:Authorization] = bearer_token
      end

      describe "JSON Index API" do
        let(:parsed_response) { JSON.parse(response.body) }

        it "returns correct jsonapi content type header" do
          get "/api/v1/participants/ecf"
          expect(response.headers["Content-Type"]).to eql("application/vnd.api+json")
        end

        it "returns all users" do
          get "/api/v1/participants/ecf"
          expect(parsed_response["data"].size).to eql(4)
        end

        it "only returns users for the current cohort" do
          cohort_2020 = create(:cohort, start_year: 2020)
          partnership_2020 = create(:partnership, lead_provider:, cohort: cohort_2020)
          school_cohort_2020 = create(:school_cohort, school: partnership_2020.school, cohort: cohort_2020, induction_programme_choice: "full_induction_programme")
          create(:ect_participant_profile, school_cohort: school_cohort_2020)

          get "/api/v1/participants/ecf"
          expect(parsed_response["data"].size).to eql(4)
        end

        it "when user is NQT+1 and a mentor, the mentor profile is used" do
          cohort_2020 = create(:cohort, start_year: 2020)
          partnership_2020 = create(:partnership, lead_provider:, cohort: cohort_2020)
          school_cohort_2020 = create(:school_cohort, school: partnership_2020.school, cohort: cohort_2020, induction_programme_choice: "full_induction_programme")
          create(:ect_participant_profile, school_cohort: school_cohort_2020, teacher_profile: mentor_profile.teacher_profile)

          get "/api/v1/participants/ecf"
          expect(parsed_response["data"].size).to eql(4)

          parsed_response["data"].each do |user|
            next unless user["id"] == mentor_profile.user.id

            expect(user["attributes"]["cohort"]).to eq("2021")
            expect(user["attributes"]["participant_type"]).to eq("mentor")
            expect(user["attributes"]["mentor_id"]).to be_nil
          end
        end

        it "returns correct type" do
          get "/api/v1/participants/ecf"
          expect(parsed_response["data"][0]).to have_type("participant")
        end

        it "returns IDs" do
          get "/api/v1/participants/ecf"
          expect(parsed_response["data"][0]["id"]).to be_in(User.pluck(:id))
        end

        it "has correct attributes" do
          get "/api/v1/participants/ecf"
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
          get "/api/v1/participants/ecf"

          mentors = parsed_response["data"].count { |h| h["attributes"]["participant_type"] == "mentor" }
          withdrawn = parsed_response["data"].count { |h| h["attributes"]["status"] == "withdrawn" }
          ects = parsed_response["data"].count { |h| h["attributes"]["participant_type"] == "ect" }

          expect(mentors).to eql(1)
          expect(ects).to eql(3)
          expect(withdrawn).to eql(1)
        end

        it "returns the right number of users per page" do
          get "/api/v1/participants/ecf", params: { page: { per_page: 2, page: 1 } }
          expect(parsed_response["data"].size).to eql(2)
        end

        it "returns different users for each page" do
          get "/api/v1/participants/ecf", params: { page: { per_page: 2, page: 1 } }
          expect(parsed_response["data"].size).to eql(2)
          first_page_id = parsed_response["data"].first["id"]

          get "/api/v1/participants/ecf", params: { page: { per_page: 2, page: 2 } }
          second_parsed_response = JSON.parse(response.body)
          second_page_ids = second_parsed_response["data"].map { |item| item["id"] }
          expect(second_parsed_response["data"].size).to eql(2)
          expect(second_page_ids).not_to include first_page_id
        end

        it "returns users in a consistent order" do
          users = User.all
          users.first.participant_profiles.each { |pp| pp.induction_records.first.update!(created_at: 1.day.ago) }
          users.last.participant_profiles.each { |pp| pp.induction_records.first.update!(created_at: 2.days.ago) }

          get "/api/v1/participants/ecf"
          expect(parsed_response["data"][0]["id"]).to eq User.last.id
          expect(parsed_response["data"][1]["id"]).to eq User.first.id
        end

        context "when updated_since parameter is supplied" do
          before do
            User.first.update!(updated_at: 2.days.ago)
          end

          it "returns users changed since the updated_since parameter" do
            get "/api/v1/participants/ecf", params: { filter: { updated_since: 1.day.ago.iso8601 } }
            expect(parsed_response["data"].size).to eql(3)
          end

          it "returns users changed since the updated_since parameter with other formats" do
            User.first.update!(updated_at: Date.new(1970, 1, 1))
            get "/api/v1/participants/ecf", params: { filter: { updated_since: "1980-01-01T00%3A00%3A00%2B01%3A00" } }
            expect(parsed_response["data"].size).to eql(3)
          end

          context "when updated_since parameter is encoded/escaped" do
            it "unescapes the value and returns users changed since the updated_since date" do
              since = URI.encode_www_form_component(1.day.ago.iso8601)
              get "/api/v1/participants/ecf", params: { filter: { updated_since: since } }
              expect(parsed_response["data"].size).to eql(3)
            end
          end

          context "when updated_since in an invalid format" do
            it "returns a 400 status" do
              get "/api/v1/participants/ecf", params: { filter: { updated_since: "23rm21" } }
              expect(response.status).to eq 400
            end
          end
        end
        context "when the participant is withdrawn with this lead provider but has another active profile not associated with the provider" do
          let!(:active_profile_with_other_provider) { create(:ect_participant_profile, teacher_profile: withdrawn_ect_profile_record.teacher_profile) }

          it "shows the participant as withdrawn" do
            get "/api/v1/participants/ecf"
            matching_records = parsed_response["data"].select { |record| record["id"] == active_profile_with_other_provider.user.id }
            expect(matching_records.size).to eql 1
            expect(matching_records.first["attributes"]["status"]).to eql "withdrawn"
          end

          it "does not include personal information of the participant" do
            get "/api/v1/participants/ecf"
            matching_records = parsed_response["data"].select { |record| record["id"] == active_profile_with_other_provider.user.id }
            expect(matching_records.first["attributes"]["full_name"]).to eql(active_profile_with_other_provider.user.full_name)
            expect(matching_records.first["attributes"]["email"]).to be_nil
            expect(matching_records.first["attributes"]["teacher_reference_number"]).to eql(active_profile_with_other_provider.teacher_profile.trn)
          end
        end

        # skip until after identities backfilled
        xcontext "when the participant is de-duped" do
          let(:primary_user) { create(:user, email: "primary@example.com") }
          let(:primary_teacher_profile) { create(:teacher_profile, user: primary_user, trn: "1234567", school: school_cohort.school) }
          let!(:primary_npq_profile) { create(:npq_participant_profile, teacher_profile: primary_teacher_profile) }

          let(:dup_user) { create(:user, email: "duplicate@example.com") }
          let(:dup_teacher_profile) { create(:teacher_profile, user: dup_user, trn: "9990001") }
          let!(:dup_profile) { create(:ect_participant_profile, school_cohort:, teacher_profile: dup_teacher_profile, school: school_cohort.school) }

          before do
            Identity::Transfer.call(from_user: dup_user, to_user: primary_user)
            dup_user.reload
            primary_user.reload
          end

          it "exposes the original ID and email" do
            get "/api/v1/participants/ecf"
            matching_records = parsed_response["data"].select { |record| record["id"] == dup_user.id }
            expect(matching_records.count).to eq 1
            expect(matching_records.first["attributes"]["email"]).to eq dup_user.email
            expect(matching_records.first["attributes"]["full_name"]).to eq primary_user.full_name
            expect(matching_records.first["attributes"]["teacher_reference_number"]).to eq primary_user.teacher_profile.trn
          end
        end
      end

      describe "CSV Index API" do
        let(:parsed_response) { CSV.parse(response.body, headers: true) }
        before do
          get "/api/v1/participants/ecf.csv"
        end

        it "returns the correct CSV content type header" do
          expect(response.headers["Content-Type"]).to eql("text/csv")
        end

        it "returns all users" do
          expect(parsed_response.length).to eql 4
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
          expect(mentor_row["cohort"]).to eql partnership.cohort.start_year.to_s
          expect(mentor_row["teacher_reference_number"]).to eql mentor.teacher_profile.trn
          expect(mentor_row["teacher_reference_number_validated"]).to eql "false"
          expect(mentor_row["eligible_for_funding"]).to be_empty
          expect(mentor_row["pupil_premium_uplift"]).to eql "false"
          expect(mentor_row["sparsity_uplift"]).to eql "false"
          expect(mentor_row["training_status"]).to eql "active"

          ect = ParticipantProfile::ECT.active_record.first.user
          ect_row = parsed_response.find { |row| row["id"] == ect.id }
          expect(ect_row).not_to be_nil
          expect(ect_row["email"]).to eql ect.email
          expect(ect_row["full_name"]).to eql ect.full_name
          expect(ect_row["mentor_id"]).to eql mentor.id
          expect(ect_row["school_urn"]).to eql mentor.participant_profiles[0].induction_records[0].school_cohort.school.urn
          expect(ect_row["participant_type"]).to eql "ect"
          expect(ect_row["cohort"]).to eql partnership.cohort.start_year.to_s
          expect(ect_row["teacher_reference_number"]).to eql ect.teacher_profile.trn
          expect(ect_row["teacher_reference_number_validated"]).to eql "false"
          expect(mentor_row["eligible_for_funding"]).to be_empty
          expect(mentor_row["pupil_premium_uplift"]).to eql "false"
          expect(mentor_row["sparsity_uplift"]).to eql "false"
          expect(mentor_row["training_status"]).to eql "active"

          withdrawn_record_row = parsed_response.find { |row| row["id"] == withdrawn_ect_profile_record.user.id }
          expect(withdrawn_record_row).not_to be_nil
          expect(withdrawn_record_row["email"]).to be_empty
          expect(withdrawn_record_row["full_name"]).to eql(withdrawn_ect_profile_record.user.full_name)
          expect(withdrawn_record_row["mentor_id"]).to be_empty
          expect(withdrawn_record_row["school_urn"]).to eql withdrawn_ect_profile_record.induction_records[0].school_cohort.school.urn
          expect(withdrawn_record_row["participant_type"]).to eql(withdrawn_ect_profile_record.participant_type.to_s)
          expect(withdrawn_record_row["cohort"]).to eql(withdrawn_ect_profile_record.cohort.start_year.to_s)
          expect(withdrawn_record_row["teacher_reference_number"]).to eql(withdrawn_ect_profile_record.teacher_profile.trn)
          expect(withdrawn_record_row["teacher_reference_number_validated"]).to be_present
          expect(withdrawn_record_row["eligible_for_funding"]).to be_empty
          expect(withdrawn_record_row["pupil_premium_uplift"]).to eql(withdrawn_ect_profile_record.pupil_premium_uplift.to_s)
          expect(withdrawn_record_row["sparsity_uplift"]).to eql(withdrawn_ect_profile_record.sparsity_uplift.to_s)
          expect(withdrawn_record_row["training_status"]).to eql(withdrawn_ect_profile_record.induction_records.first.training_status)
        end

        it "ignores pagination parameters" do
          get "/api/v1/participants/ecf.csv", params: { page: { per_page: 2, page: 1 } }
          expect(parsed_response.length).to eql 4
        end

        it "respects the updated_since parameter" do
          User.first.update!(updated_at: 2.days.ago)
          get "/api/v1/participants/ecf.csv", params: { filter: { updated_since: 1.day.ago.iso8601 } }
          expect(parsed_response.length).to eql(3)
        end
      end

      it_behaves_like "JSON Participant Change schedule endpoint"

      describe "JSON Participant Withdrawal" do
        it_behaves_like "a participant withdraw action endpoint" do
          let(:url) { "/api/v1/participants/ecf/#{early_career_teacher_profile.user.id}/withdraw" }
          let(:params) { { data: { attributes: { course_identifier: "ecf-induction", reason: "moved-school" } } } }
          let(:induction_programme) { create(:induction_programme, partnership:) }

          it "changes the training status of a participant to withdrawn" do
            put url, params: params

            expect(response).to be_successful
            expect(parsed_response.dig("data", "attributes", "training_status")).to eql("withdrawn")
          end
        end
      end

      it_behaves_like "JSON Participant Resume endpoint", "participant" do
        let(:url)               { "/api/v1/participants/ecf/#{early_career_teacher_profile.user.id}/resume" }
        let(:withdrawal_url)    { "/api/v1/participants/ecf/#{early_career_teacher_profile.user.id}/withdraw" }
        let(:params)            { { data: { attributes: { course_identifier: "ecf-induction" } } } }
        let(:withdrawal_params) { { data: { attributes: { course_identifier: "ecf-induction", reason: "left-teaching-profession" } } } }
        let(:induction_programme) { create(:induction_programme, partnership:) }

        before do
          put "/api/v1/participants/ecf/#{early_career_teacher_profile.user.id}/defer",
              params: { data: { attributes: { course_identifier: "ecf-induction", reason: "career-break" } } }
        end
      end
    end

    context "when unauthorized" do
      before { default_headers[:Authorization] }

      it "returns 401 for invalid bearer token" do
        default_headers[:Authorization] = "Bearer ugLPicDrpGZdD_w7hhCL"
        get "/api/v1/participants/ecf"
        expect(response.status).to eq 401
      end
    end

    context "when using a engage and learn token" do
      let(:token) { EngageAndLearnApiToken.create_with_random_token! }

      it "returns 401 for invalid bearer token" do
        default_headers[:Authorization] = bearer_token
        get "/api/v1/participants/ecf"
        expect(response.status).to eq 403
      end
    end

    context "when using LeadProviderApiToken with only NPQ access" do
      let(:cpd_lead_provider) { create(:cpd_lead_provider, npq_lead_provider:, lead_provider: nil) }
      let(:npq_lead_provider) { create(:npq_lead_provider) }
      let(:token) { LeadProviderApiToken.create_with_random_token!(cpd_lead_provider:) }

      it "returns 403" do
        default_headers[:Authorization] = bearer_token
        get "/api/v1/participants/ecf"
        expect(response.status).to eq 403
      end
    end
  end

  it_behaves_like "JSON Participant Deferral endpoint", "participant" do
    let(:url)               { "/api/v1/participants/#{early_career_teacher_profile.user.id}/defer" }
    let(:params)            { { data: { attributes: { course_identifier: "ecf-induction", reason: "career-break" } } } }
    let(:withdrawal_url)    { "/api/v1/participants/#{early_career_teacher_profile.user.id}/withdraw" }
    let(:withdrawal_params) { { data: { attributes: { course_identifier: "ecf-induction", reason: "left-teaching-profession" } } } }
    let(:induction_programme) { create(:induction_programme, partnership:) }
    let!(:induction_record) do
      Induction::Enrol.call(participant_profile: early_career_teacher_profile, induction_programme:)
    end
  end
end
