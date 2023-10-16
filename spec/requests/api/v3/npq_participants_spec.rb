# frozen_string_literal: true

require "rails_helper"

RSpec.describe "NPQ Participants API", type: :request do
  let(:token) { LeadProviderApiToken.create_with_random_token!(cpd_lead_provider:) }
  let(:bearer_token) { "Bearer #{token}" }
  let(:npq_lead_provider) { create(:npq_lead_provider) }
  let(:cpd_lead_provider) { create(:cpd_lead_provider, npq_lead_provider:) }
  let(:parsed_response) { JSON.parse(response.body) }
  let!(:npq_applications) do
    create_list(:npq_application, 3, :accepted, :with_started_declaration, npq_lead_provider:, school_urn: "123456")
  end

  before { default_headers[:Authorization] = bearer_token }

  describe "GET /api/v3/participants/npq", with_feature_flags: { participant_id_changes: "active" } do
    context "when authorized" do
      let(:npq_application) { npq_applications.sample }
      let(:npq_course)      { npq_application.npq_course }

      describe "JSON Index API" do
        let(:npq_course) { npq_applications.sample.npq_course }

        it "returns correct jsonapi content type header" do
          get "/api/v3/participants/npq"
          expect(response.headers["Content-Type"]).to eql("application/vnd.api+json")
        end

        it "returns all accepted users" do
          get "/api/v3/participants/npq"
          expect(parsed_response["data"].size).to eql(3)
        end

        it "returns correct type" do
          get "/api/v3/participants/npq"
          expect(parsed_response["data"][0]).to have_type("npq-participant")
        end

        it "returns correct data" do
          get "/api/v3/participants/npq"

          user = User.find(parsed_response["data"][0]["id"])
          expect(parsed_response["data"][0]["id"]).to be_in(ParticipantIdentity.joins(:npq_applications).pluck(:user_id))
          expect(parsed_response["data"][0]["attributes"]["full_name"]).to eql(user.full_name)
          expect(parsed_response["data"][0]["attributes"]["teacher_reference_number"]).to eql(user.teacher_profile.trn)
          expect(parsed_response["data"][0]["attributes"]["updated_at"]).to eql(user.updated_at.rfc3339)
        end

        it "has correct attributes" do
          get "/api/v3/participants/npq"

          expect(parsed_response["data"][0])
            .to(have_jsonapi_attributes(
              :full_name,
              :teacher_reference_number,
              :updated_at,
              :npq_enrolments,
              :participant_id_changes,
            ).exactly)
        end

        it "can return paginated data" do
          get "/api/v3/participants/npq", params: { page: { per_page: 2, page: 1 } }
          expect(parsed_response["data"].size).to eql(2)

          get "/api/v3/participants/npq", params: { page: { per_page: 2, page: 2 } }
          expect(JSON.parse(response.body)["data"].size).to eql(1)
        end

        context "filtering" do
          before do
            travel_to 10.days.ago do
              create_list(:npq_application, 3,
                          :accepted,
                          npq_lead_provider:,
                          school_urn: "123456",
                          npq_course:).each do |application|
                application.profile.update!(training_status: :withdrawn)
              end
            end
          end

          it "returns matching users when filtering by training_status" do
            get "/api/v3/participants/npq", params: { filter: { training_status: :withdrawn } }

            expect(parsed_response["data"].size).to eq(3)
          end

          it "returns an error when the training_status is not valid" do
            get "/api/v3/participants/npq", params: { filter: { training_status: :invalid } }

            expect(response).to be_bad_request
            expect(parsed_response).to eql(HashWithIndifferentAccess.new({
              "errors": [
                {
                  "title": "Bad request",
                  "detail": %(The filter '#/training_status' must be ["active", "deferred", "withdrawn"]),
                },
              ],
            }))
          end

          it "returns content updated after specified timestamp" do
            get "/api/v3/participants/npq", params: { filter: { updated_since: 2.days.ago.iso8601 } }

            expect(parsed_response["data"].size).to eq(3)
          end

          context "with filter from_participant_id" do
            let(:user) { create(:npq_participant_profile, npq_lead_provider:, npq_course:, training_status: :withdrawn).user }
            let!(:participant_id_change1) { create(:participant_id_change, to_participant: user, user:) }
            let(:from_participant_id) { participant_id_change1.from_participant_id }

            it "returns matching users when filtering by from_participant_id" do
              get "/api/v3/participants/npq", params: { filter: { from_participant_id: } }

              expect(parsed_response["data"].size).to eq(1)
            end

            it "returns empty array if from_participant_id does not exist" do
              get "/api/v3/participants/npq", params: { filter: { from_participant_id: "doesnotexist" } }

              expect(parsed_response["data"].size).to eq(0)
            end
          end

          context "with invalid filter of a string" do
            it "returns an error" do
              get "/api/v3/participants/npq", params: { filter: 2.days.ago.iso8601 }
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

        describe "ordering" do
          let!(:another_npq_application) { create(:npq_application, :accepted, npq_lead_provider:, school_urn: "123456", npq_course:) }

          before do
            another_npq_application.user.update!(updated_at: 5.days.ago)
          end

          context "when ordering by updated_at ascending" do
            let(:sort_param) { "updated_at" }

            before do
              get "/api/v3/participants/npq", params: { sort: sort_param }
            end

            it "returns an ordered list of npq participants" do
              expect(parsed_response["data"].size).to eql(4)
              expect(parsed_response.dig("data", 0, "attributes", "full_name")).to eql(another_npq_application.user.full_name)
            end
          end

          context "when ordering by updated_at descending" do
            let(:sort_param) { "-updated_at" }

            before do
              get "/api/v3/participants/npq", params: { sort: sort_param }
            end

            it "returns an ordered list of npq participants" do
              expect(parsed_response["data"].size).to eql(4)
              expect(parsed_response.dig("data", 3, "attributes", "full_name")).to eql(another_npq_application.user.full_name)
            end
          end

          context "when not including sort in the params" do
            before do
              another_npq_application.profile.update!(created_at: 10.days.ago)

              get "/api/v3/participants/npq", params: { sort: "" }
            end

            it "returns all records ordered by profiles created_at" do
              expect(parsed_response["data"].size).to eql(4)
              expect(parsed_response.dig("data", 0, "attributes", "full_name")).to eql(another_npq_application.user.full_name)
            end
          end
        end
      end
    end

    context "when unauthorized" do
      it "returns 401 for invalid bearer token" do
        default_headers[:Authorization] = "Bearer ugLPicDrpGZdD_w7hhCL"
        get "/api/v3/participants/npq"
        expect(response.status).to eq 401
      end
    end

    context "when using a engage and learn token" do
      let(:token) { EngageAndLearnApiToken.create_with_random_token! }

      it "returns 401 for invalid bearer token" do
        default_headers[:Authorization] = bearer_token
        get "/api/v3/participants/npq"
        expect(response.status).to eq 403
      end
    end
  end

  describe "GET /api/v3/participants/npq/:id", with_feature_flags: { participant_id_changes: "active" } do
    let(:npq_application) { create(:npq_application, :accepted, :with_started_declaration, npq_lead_provider:) }
    let(:npq_participant) { npq_application.profile }

    before do
      default_headers[:Authorization] = bearer_token
      get "/api/v3/participants/npq/#{npq_participant.user_id}"
    end

    context "when authorized" do
      it "returns correct jsonapi content type header" do
        expect(response.headers["Content-Type"]).to eql("application/vnd.api+json")
      end

      it "returns 200" do
        expect(response.status).to eq 200
      end

      it "returns correct type" do
        expect(parsed_response["data"]).to have_type("npq-participant")
      end

      it "returns correct data" do
        user = User.find(parsed_response["data"]["id"])
        expect(parsed_response["data"]["id"]).to be_in(ParticipantIdentity.joins(:npq_applications).pluck(:user_id))
        expect(parsed_response["data"]["attributes"]["full_name"]).to eql(user.full_name)
        expect(parsed_response["data"]["attributes"]["teacher_reference_number"]).to eql(user.teacher_profile.trn)
        expect(parsed_response["data"]["attributes"]["updated_at"]).to eql(user.updated_at.rfc3339)
      end

      it "has correct attributes" do
        expect(parsed_response["data"])
          .to(have_jsonapi_attributes(
            :full_name,
            :teacher_reference_number,
            :updated_at,
            :npq_enrolments,
            :participant_id_changes,
          ).exactly)
      end
    end

    context "when unauthorized" do
      let(:token) { "wrong_token" }

      it "returns 401 for invalid bearer token" do
        expect(response.status).to eq 401
      end
    end
  end

  describe "PUT /api/v3/participants/npq/:id/change-schedule" do
    let(:npq_application) { create(:npq_application, :accepted, npq_lead_provider:) }
    let(:profile) { npq_application.profile }
    let(:new_schedule) do
      if Finance::Schedule::NPQLeadership::IDENTIFIERS.include?(profile.npq_course.identifier)
        create(:npq_leadership_schedule, schedule_identifier: SecureRandom.alphanumeric)
      elsif Finance::Schedule::NPQSpecialist::IDENTIFIERS.include?(profile.npq_course.identifier)
        create(:npq_specialist_schedule, schedule_identifier: SecureRandom.alphanumeric)
      else
        create(:npq_aso_schedule, schedule_identifier: SecureRandom.alphanumeric)
      end
    end
    let!(:contract) { create(:npq_contract, npq_course: npq_application.npq_course, npq_lead_provider: npq_application.npq_lead_provider) }

    it "changes the schedules of the specified profile", :aggregate_failures do
      put "/api/v3/participants/npq/#{npq_application.profile.user_id}/change-schedule", params: {
        data: {
          type: "participant-change-schedule",
          attributes: {
            schedule_identifier: new_schedule.schedule_identifier,
            course_identifier: npq_application.npq_course.identifier,
            cohort: new_schedule.cohort.start_year,
          },
        },
      }

      expect(response).to be_successful
      expect(npq_application.profile.reload.schedule).to eq(new_schedule)
    end
  end

  describe "JSON Participant Withdrawal endpoint" do
    let(:npq_application)   { npq_applications.sample }
    let(:npq_course)        { npq_application.npq_course }
    let(:profile)           { npq_application.profile }
    let(:url) { "/api/v3/participants/npq/#{npq_application.user.id}/withdraw" }
    let(:withdrawal_reason) { ParticipantProfile::NPQ::WITHDRAW_REASONS.sample }
    let(:params) do
      { data: { attributes: { course_identifier: npq_course.identifier, reason: withdrawal_reason } } }
    end

    context "when there is a started declaration" do
      it_behaves_like "JSON Participant Withdrawal endpoint" do
        it "changes the training status of a participant to withdrawn" do
          put(url, params:)

          expect(response).to be_successful
          expect(npq_application.reload.profile.training_status).to eql("withdrawn")
        end
      end
    end

    context "when withdrawn reason is expected-commitment-unclear" do
      let(:withdrawal_reason) { "expected-commitment-unclear" }

      it "withdraws with reason expected-commitment-unclear" do
        put(url, params:)

        expect(response).to be_successful
        expect(npq_application.reload.profile.participant_profile_state.reason).to eql(withdrawal_reason)
      end
    end

    context "when there are no started declarations" do
      let(:npq_application) { create(:npq_application, :accepted, npq_lead_provider:, school_urn: "123456") }

      it "returns an error message" do
        put(url, params:)

        expect(response.status).to eq(422)
      end
    end
  end

  it_behaves_like "JSON Participant Deferral endpoint", "npq-participant" do
    let(:npq_application)   { npq_applications.sample }
    let(:npq_course)        { npq_application.npq_course }
    let(:profile)           { npq_application.profile }
    let(:course_identifier) { npq_course.identifier }
    let(:url)               { "/api/v3/participants/npq/#{npq_application.user.id}/defer" }
    let(:withdrawal_url)    { "/api/v3/participants/npq/#{npq_application.user.id}/withdraw" }
    let(:params)            { { data: { attributes: { course_identifier:, reason: ParticipantProfile::DEFERRAL_REASONS.sample } } } }
    let(:withdrawal_params) { { data: { attributes: { course_identifier:, reason: ParticipantProfile::NPQ::WITHDRAW_REASONS.sample } } } }
  end

  it_behaves_like "JSON Participant Resume endpoint", "npq-participant" do
    let(:npq_application)   { npq_applications.sample }
    let(:npq_course)        { npq_application.npq_course }
    let(:profile)           { npq_application.profile }
    let(:course_identifier) { npq_course.identifier }
    let(:url)               { "/api/v3/participants/npq/#{npq_application.user.id}/resume" }
    let(:withdrawal_url)    { "/api/v3/participants/npq/#{npq_application.user.id}/withdraw" }
    let(:params)            { { data: { attributes: { course_identifier: } } } }
    let(:withdrawal_params) { { data: { attributes: { course_identifier:, reason: ParticipantProfile::NPQ::WITHDRAW_REASONS.sample } } } }
    before do
      put "/api/v3/participants/npq/#{npq_application.user.id}/defer",
          params: { data: { attributes: { course_identifier:, reason: ParticipantProfile::DEFERRAL_REASONS.sample } } }
    end
  end
end
