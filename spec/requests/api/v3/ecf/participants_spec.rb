# frozen_string_literal: true

require "rails_helper"

RSpec.describe "API ECF Participants", :with_default_schedules, type: :request, with_feature_flags: { api_v3: "active" } do
  let(:cohort_2021) { Cohort.find_by(start_year: 2021) || create(:cohort, start_year: 2021) }
  let(:cpd_lead_provider) { create(:cpd_lead_provider, lead_provider:) }
  let(:lead_provider)     { create(:lead_provider) }
  let(:token)             { LeadProviderApiToken.create_with_random_token!(cpd_lead_provider:) }
  let(:bearer_token)      { "Bearer #{token}" }
  let!(:school_cohort) { create(:school_cohort, :fip, :with_induction_programme, lead_provider: cpd_lead_provider.lead_provider, cohort: cohort_2021) }
  let!(:mentor_profile) do
    travel_to 3.days.ago do
      create(:mentor, school_cohort:, lead_provider:)
    end
  end

  before do
    travel_to 2.days.ago do
      create_list :ect, 2, mentor_profile_id: mentor_profile.id, lead_provider:, school_cohort:
    end

    ect_teacher_profile_with_one_active_and_one_withdrawn_profile_record = ParticipantProfile::ECT.first.teacher_profile
    create(
      :ect,
      :withdrawn_record,
      school_cohort:,
      teacher_profile: ect_teacher_profile_with_one_active_and_one_withdrawn_profile_record,
      lead_provider:,
    )
    default_headers[:Authorization] = bearer_token
  end

  let!(:withdrawn_ect_profile_record) { create(:ect, :withdrawn_record, school_cohort:, lead_provider:) }
  let(:early_career_teacher_profile) { create(:ect, :eligible_for_funding, school_cohort:) }

  describe "GET /api/v3/participants/ecf" do
    context "when authorized" do
      before do
        default_headers[:Authorization] = bearer_token
      end

      describe "JSON Index API" do
        let(:parsed_response) { JSON.parse(response.body) }

        it "returns correct jsonapi content type header" do
          get "/api/v3/participants/ecf"
          expect(response.headers["Content-Type"]).to eql("application/vnd.api+json")
        end

        it "returns all users" do
          get "/api/v3/participants/ecf"
          expect(parsed_response["data"].size).to eql(4)
        end

        it "only returns users for the current cohort" do
          cohort_2020 = Cohort.find_by(start_year: 2020) || create(:cohort, start_year: 2020)
          partnership_2020 = create(:partnership, lead_provider:, cohort: cohort_2020)
          school_cohort_2020 = create(:school_cohort, school: partnership_2020.school, cohort: cohort_2020, induction_programme_choice: "full_induction_programme")
          create(:ect_participant_profile, school_cohort: school_cohort_2020)

          get "/api/v3/participants/ecf"
          expect(parsed_response["data"].size).to eql(4)
        end

        it "when user is NQT+1 and a mentor, the mentor profile is used" do
          cohort_2020 = Cohort.find_by(start_year: 2020) || create(:cohort, start_year: 2020)
          partnership_2020 = create(:partnership, lead_provider:, cohort: cohort_2020)
          school_cohort_2020 = create(:school_cohort, school: partnership_2020.school, cohort: cohort_2020, induction_programme_choice: "full_induction_programme")
          create(:ect_participant_profile, school_cohort: school_cohort_2020, teacher_profile: mentor_profile.teacher_profile)

          get "/api/v3/participants/ecf"
          expect(parsed_response["data"].size).to eql(4)

          parsed_response["data"].each do |user|
            next unless user["id"] == mentor_profile.user.id

            expect(user["attributes"]["ecf_enrolments"][0]["cohort"]).to eq("2021")
            expect(user["attributes"]["ecf_enrolments"][0]["participant_type"]).to eq("mentor")
            expect(user["attributes"]["ecf_enrolments"][0]["mentor_id"]).to be_nil
          end
        end

        it "returns correct type" do
          get "/api/v3/participants/ecf"
          expect(parsed_response["data"][0]).to have_type("participant")
        end

        it "returns IDs" do
          get "/api/v3/participants/ecf"
          expect(parsed_response["data"][0]["id"]).to be_in(User.pluck(:id))
        end

        it "has correct attributes" do
          get "/api/v3/participants/ecf"

          expect(parsed_response["data"][0])
            .to(have_jsonapi_attributes(
              :full_name,
              :teacher_reference_number,
              :updated_at,
              :ecf_enrolments,
            ).exactly)
        end

        it "returns correct user types" do
          get "/api/v3/participants/ecf"

          mentors = parsed_response["data"].count { |h| h["attributes"]["ecf_enrolments"][0]["participant_type"] == "mentor" }
          ects = parsed_response["data"].count { |h| h["attributes"]["ecf_enrolments"][0]["participant_type"] == "ect" }

          expect(mentors).to eql(1)
          expect(ects).to eql(3)
        end

        it "returns the right number of users per page" do
          get "/api/v3/participants/ecf", params: { page: { per_page: 2, page: 1 } }
          expect(parsed_response["data"].size).to eql(2)
        end

        it "returns different users for each page" do
          get "/api/v3/participants/ecf", params: { page: { per_page: 2, page: 1 } }
          expect(parsed_response["data"].size).to eql(2)
          first_page_id = parsed_response["data"].first["id"]

          get "/api/v3/participants/ecf", params: { page: { per_page: 2, page: 2 } }
          second_parsed_response = JSON.parse(response.body)
          second_page_ids = second_parsed_response["data"].map { |item| item["id"] }
          expect(second_parsed_response["data"].size).to eql(2)
          expect(second_page_ids).not_to include first_page_id
        end

        it "returns users in a consistent order" do
          get "/api/v3/participants/ecf"

          expect(parsed_response["data"].first["id"]).to eq User.order(created_at: :asc).first.id
          expect(parsed_response["data"].last["id"]).to eq User.order(created_at: :asc).last.id
        end

        context "when updated_since parameter is supplied" do
          it "returns users changed since the updated_since parameter" do
            get "/api/v3/participants/ecf", params: { filter: { updated_since: 1.day.ago.iso8601 } }

            expect(parsed_response["data"].size).to eq(2)
          end

          it "returns users changed since the updated_since parameter with other formats" do
            User.order(created_at: :asc).first.update!(updated_at: Date.new(1970, 1, 1))
            get "/api/v3/participants/ecf", params: { filter: { updated_since: "1980-01-01T00%3A00%3A00%2B01%3A00" } }
            expect(parsed_response["data"].size).to eq(3)
          end

          context "when updated_since parameter is encoded/escaped" do
            it "unescapes the value and returns users changed since the updated_since date" do
              since = URI.encode_www_form_component(1.day.ago.iso8601)
              get "/api/v3/participants/ecf", params: { filter: { updated_since: since } }
              expect(parsed_response["data"].size).to eq(2)
            end
          end

          context "when updated_since in an invalid format" do
            it "returns a 400 status" do
              get "/api/v3/participants/ecf", params: { filter: { updated_since: "23rm21" } }
              expect(response).to be_bad_request
            end

            it "returns a meaningful error message" do
              get "/api/v3/participants/ecf", params: { filter: { updated_since: "23rm21" } }

              expect(parsed_response).to eql(HashWithIndifferentAccess.new({
                "errors": [
                  {
                    "title": "Bad request",
                    "detail": "The filter '#/updated_since' must be a valid RCF3339 date",
                  },
                ],
              }))
            end
          end
        end

        context "when cohort parameter is supplied" do
          it "returns participants only within that cohort" do
            next_cohort = Cohort.find_by(start_year: 2022) || create(:cohort, start_year: 2022)
            next_partnership = create(:partnership, lead_provider:, cohort: next_cohort)
            next_school_cohort = create(:school_cohort, school: next_partnership.school, cohort: next_cohort, induction_programme_choice: "full_induction_programme")
            next_induction_programme = create(:induction_programme, school_cohort: next_school_cohort, partnership: next_partnership)
            next_schedule = create(:schedule, name: "ECF September 2022", cohort: next_cohort)
            next_participant_profile = create(:ect_participant_profile, school_cohort: next_school_cohort, schedule: next_schedule)
            create(:induction_record, participant_profile: next_participant_profile, induction_programme: next_induction_programme, schedule: next_schedule)

            get "/api/v3/participants/ecf", params: { filter: { cohort: 2021 } }
            expect(parsed_response["data"].size).to eq(4)
          end

          it "returns no participants if cohort is not associated to any participants" do
            get "/api/v3/participants/ecf", params: { filter: { cohort: 2018 } }
            expect(parsed_response["data"].size).to eq(0)
          end
        end

        context "when the participant is withdrawn with this lead provider but has another active profile not associated with the provider" do
          let!(:active_profile_with_other_provider) { create(:ect_participant_profile, teacher_profile: withdrawn_ect_profile_record.teacher_profile) }

          it "shows the participant as withdrawn" do
            get "/api/v3/participants/ecf"

            matching_records = parsed_response["data"].select { |record| record["id"] == active_profile_with_other_provider.user.id }
            expect(matching_records.size).to eql 1
            expect(matching_records.first["attributes"]["ecf_enrolments"][0]["participant_status"]).to eql "withdrawn"
          end
        end
      end
    end

    context "when unauthorized" do
      before { default_headers[:Authorization] }

      it "returns 401 for invalid bearer token" do
        default_headers[:Authorization] = "Bearer ugLPicDrpGZdD_w7hhCL"
        get "/api/v3/participants/ecf"
        expect(response.status).to eq 401
      end
    end

    context "when using a engage and learn token" do
      let(:token) { EngageAndLearnApiToken.create_with_random_token! }

      it "returns 401 for invalid bearer token" do
        default_headers[:Authorization] = bearer_token
        get "/api/v3/participants/ecf"
        expect(response.status).to eq 403
      end
    end

    context "when using LeadProviderApiToken with only NPQ access" do
      let(:cpd_lead_provider) { create(:cpd_lead_provider, npq_lead_provider:, lead_provider: nil) }
      let(:npq_lead_provider) { create(:npq_lead_provider) }
      let(:token) { LeadProviderApiToken.create_with_random_token!(cpd_lead_provider:) }

      it "returns 403" do
        default_headers[:Authorization] = bearer_token
        get "/api/v3/participants/ecf"
        expect(response.status).to eq 403
      end
    end
  end

  describe "GET /api/v3/participants/ecf/:id", :with_default_schedules do
    let(:parsed_response) { JSON.parse(response.body) }

    before do
      default_headers[:Authorization] = bearer_token
      travel_to Time.zone.local(2022, 7, 22, 11, 30, 0) do
        get "/api/v3/participants/ecf/#{early_career_teacher_profile.user_id}"
      end
    end

    context "when authorized" do
      let(:expected_response) do
        HashWithIndifferentAccess.new({
          "data": {
            "id": early_career_teacher_profile.user_id,
            "type": "participant",
            "attributes": {
              "full_name": early_career_teacher_profile.user.full_name,
              "teacher_reference_number": early_career_teacher_profile.teacher_profile.trn,
              "updated_at": Time.zone.local(2022, 7, 22, 11, 30, 0).rfc3339,
              "ecf_enrolments": [{
                "training_record_id": early_career_teacher_profile.id,
                "email": (early_career_teacher_profile.induction_records[0].preferred_identity&.email || early_career_teacher_profile.user.email),
                "mentor_id": early_career_teacher_profile.mentor_profile&.participant_identity&.external_identifier,
                "school_urn": early_career_teacher_profile.induction_records[0].school_cohort.school.urn,
                "participant_type": early_career_teacher_profile.participant_type.to_s,
                "cohort": early_career_teacher_profile&.cohort&.start_year&.to_s,
                "training_status": early_career_teacher_profile.induction_records[0].induction_status,
                "participant_status": early_career_teacher_profile.training_status,
                "teacher_reference_number_validated": true,
                "eligible_for_funding": true,
                "pupil_premium_uplift": early_career_teacher_profile.pupil_premium_uplift,
                "sparsity_uplift": early_career_teacher_profile.sparsity_uplift,
                "schedule_identifier": early_career_teacher_profile.induction_records[0].schedule&.schedule_identifier,
                "validation_status": nil,
                "delivery_partner_id": early_career_teacher_profile.induction_records[0].delivery_partner_id,
                "withdrawal": nil,
                "deferral": nil,
                "created_at": early_career_teacher_profile.created_at.rfc3339,
              }],
            },
          },
        })
      end

      it "returns correct jsonapi content type header" do
        expect(response.headers["Content-Type"]).to eql("application/vnd.api+json")
      end

      it "returns 200" do
        expect(response.status).to eq 200
      end

      it "returns correct data" do
        expect(parsed_response).to eq(expected_response)
      end
    end

    context "when unauthorized" do
      let(:token) { "wrong_token" }

      it "returns 401 for invalid bearer token" do
        expect(response.status).to eq 401
      end
    end
  end

  describe "JSON Participant Change Schedule endpoint" do
    let(:url) { "/api/v3/participants/ecf/#{early_career_teacher_profile.user.id}/change-schedule" }
    let(:cohort) { Cohort.find_by(start_year: 2021) || create(:cohort, start_year: 2021) }

    describe "/api/v3/participants/ID/change-schedule" do
      let(:parsed_response) { JSON.parse(response.body) }

      before do
        create(:schedule, schedule_identifier: "ecf-january-standard-2021", name: "ECF January standard 2021", cohort:)
      end

      it "changes participant schedule" do
        put url, params: {
          data: {
            attributes: {
              course_identifier: "ecf-induction",
              schedule_identifier: "ecf-january-standard-2021",
              cohort: "2021",
            },
          },
        }

        expect(response).to be_successful
        expect(parsed_response.dig("data", "attributes", "ecf_enrolments", 0, "schedule_identifier")).to eql("ecf-january-standard-2021")
      end
    end

    describe "/api/v3/participants/ID/change-schedule with cohort" do
      let(:parsed_response) { JSON.parse(response.body) }

      let!(:schedule) { create(:schedule, schedule_identifier: "schedule", name: "schedule", cohort:) }
      let!(:new_schedule) { create(:schedule, schedule_identifier: "new-schedule", name: "new schedule", cohort:) }

      it "changes participant schedule" do
        expect {
          put url, params: {
            data: {
              attributes: {
                course_identifier: "ecf-induction",
                schedule_identifier: new_schedule.schedule_identifier,
                cohort: "2021",
              },
            },
          }
        }.to change { early_career_teacher_profile.reload.schedule }.to(new_schedule)

        expect(response).to be_successful
        expect(parsed_response.dig("data", "attributes", "ecf_enrolments", 0, "schedule_identifier")).to eql(new_schedule.schedule_identifier)
      end
    end

    describe "/api/v3/participants/ecf/ID/change-schedule" do
      let(:parsed_response) { JSON.parse(response.body) }

      before do
        create(:schedule, schedule_identifier: "ecf-january-standard-2021", name: "ECF January standard 2021", cohort:)
      end

      it "changes participant schedule" do
        put url, params: {
          data: {
            attributes: {
              course_identifier: "ecf-induction",
              schedule_identifier: "ecf-january-standard-2021",
              cohort: "2021",
            },
          },
        }

        expect(response).to be_successful
        expect(parsed_response.dig("data", "attributes", "ecf_enrolments", 0, "schedule_identifier")).to eql("ecf-january-standard-2021")
      end
    end
  end

  it_behaves_like "JSON Participant Deferral endpoint", "participant" do
    let(:url) { "/api/v3/participants/ecf/#{early_career_teacher_profile.user.id}/defer" }
    let(:params) { { data: { attributes: { course_identifier: "ecf-induction", reason: "career-break" } } } }
    let(:withdrawal_url) { "/api/v3/participants/ecf/#{early_career_teacher_profile.user.id}/withdraw" }
    let(:withdrawal_params) { { data: { attributes: { course_identifier: "ecf-induction", reason: "left-teaching-profession" } } } }

    it "changes the training status of a participant to deferred" do
      put(url, params:)

      expect(response).to be_successful
      expect(parsed_response.dig("data", "attributes", "ecf_enrolments", 0, "training_status")).to eq("deferred")
    end
  end

  it_behaves_like "JSON Participant Resume endpoint", "participant" do
    let(:url) { "/api/v3/participants/ecf/#{early_career_teacher_profile.user.id}/resume" }
    let(:withdrawal_url) { "/api/v3/participants/ecf/#{early_career_teacher_profile.user.id}/withdraw" }
    let(:params)            { { data: { attributes: { course_identifier: "ecf-induction" } } } }
    let(:withdrawal_params) { { data: { attributes: { course_identifier: "ecf-induction", reason: "left-teaching-profession" } } } }

    before do
      put "/api/v3/participants/ecf/#{early_career_teacher_profile.user.id}/defer",
          params: { data: { attributes: { course_identifier: "ecf-induction", reason: "career-break" } } }
    end

    it "changes the training status of a participant to active" do
      put(url, params:)

      expect(response).to be_successful
      expect(parsed_response.dig("data", "attributes", "ecf_enrolments", 0, "training_status")).to eq("active")
    end
  end

  describe "JSON Participant Withdrawal" do
    it_behaves_like "JSON Participant Withdrawal endpoint" do
      let(:url) { "/api/v3/participants/ecf/#{early_career_teacher_profile.user.id}/withdraw" }
      let(:params) { { data: { attributes: { course_identifier: "ecf-induction", reason: "moved-school" } } } }

      it "changes the training status of a participant to withdrawn" do
        put(url, params:)

        expect(response).to be_successful
        expect(parsed_response.dig("data", "attributes", "ecf_enrolments", 0, "training_status")).to eql("withdrawn")
      end
    end
  end
end
