# frozen_string_literal: true

require "rails_helper"

RSpec.describe "NPQ Participants API", type: :request do
  let(:token) { LeadProviderApiToken.create_with_random_token!(cpd_lead_provider: cpd_lead_provider) }
  let(:bearer_token) { "Bearer #{token}" }
  let(:npq_lead_provider) { create(:npq_lead_provider) }
  let(:cpd_lead_provider) { create(:cpd_lead_provider, npq_lead_provider: npq_lead_provider) }

  before { default_headers[:Authorization] = bearer_token }

  describe "GET /api/v1/participants/npq", :with_default_schedules do
    let!(:npq_applications) do
      create_list(:npq_application, 3, :accepted, npq_lead_provider: npq_lead_provider, school_urn: "123456")
    end

    context "when authorized" do
      let(:npq_application) { npq_applications.sample }
      let(:npq_course)      { npq_application.npq_course }

      describe "JSON Index API" do
        let(:parsed_response) { JSON.parse(response.body) }
        let(:npq_course)      { npq_applications.sample.npq_course }

        it "returns correct jsonapi content type header" do
          get "/api/v1/participants/npq"
          expect(response.headers["Content-Type"]).to eql("application/vnd.api+json")
        end

        it "returns all accepted users" do
          get "/api/v1/participants/npq"
          expect(parsed_response["data"].size).to eql(3)
        end

        it "returns correct type" do
          get "/api/v1/participants/npq"
          expect(parsed_response["data"][0]).to have_type("npq-participant")
        end

        it "returns IDs" do
          get "/api/v1/participants/npq"

          user = User.find(parsed_response["data"][0]["id"])
          expect(parsed_response["data"][0]["id"]).to be_in(Identity.joins(:npq_applications).pluck(:user_id))
          teacher_profile = user.teacher_profile

          expect(parsed_response["data"][0]["attributes"]["email"]).to eql(user.email)
          expect(parsed_response["data"][0]["attributes"]["full_name"]).to eql(user.full_name)
          expect(parsed_response["data"][0]["attributes"]["teacher_reference_number"]).to eql(teacher_profile.trn)
        end

        it "has correct attributes" do
          get "/api/v1/participants/npq"
          expect(parsed_response["data"][0])
            .to(have_jsonapi_attributes(
              :participant_id,
              :npq_courses,
              :email,
              :full_name,
              :teacher_reference_number,
              :updated_at,
            ).exactly)
        end

        it "can return paginated data" do
          get "/api/v1/participants/npq", params: { page: { per_page: 2, page: 1 } }
          expect(parsed_response["data"].size).to eql(2)

          get "/api/v1/participants/npq", params: { page: { per_page: 2, page: 2 } }
          expect(JSON.parse(response.body)["data"].size).to eql(1)
        end

        context "filtering" do
          before do
            current_time = Time.zone.now
            travel_to 10.days.ago
            list = create_list(:npq_application, 3, npq_lead_provider: npq_lead_provider, school_urn: "123456", npq_course: npq_course)

            list.each do |npq_application|
              NPQ::Accept.new(npq_application: npq_application).call
            end
            travel_to current_time
          end

          it "returns content updated after specified timestamp" do
            get "/api/v1/participants/npq", params: { filter: { updated_since: 2.days.ago.iso8601 } }
            expect(parsed_response["data"].size).to eql(3)
          end

          context "with invalid filter of a string" do
            it "returns an error" do
              get "/api/v1/participants/npq", params: { filter: 2.days.ago.iso8601 }
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

      describe "JSON Participant Withdrawal" do
        it_behaves_like "a participant withdraw action endpoint" do
          let(:url) { "/api/v1/participants/npq/#{npq_application.user.id}/withdraw" }
          let(:params) do
            { data: { attributes: { course_identifier: npq_course.identifier, reason: Participants::Withdraw::NPQ.reasons.sample } } }
          end

          it "changes the training status of a participant to withdrawn" do
            put url, params: params

            expect(response).to be_successful
            expect(npq_application.reload.profile.training_status).to eql("withdrawn")
          end
        end
      end

      it_behaves_like "JSON Participant Deferral endpoint", "npq-participant" do
        let(:course_identifier) { npq_course.identifier }
        let(:url)               { "/api/v1/participants/npq/#{npq_application.user.id}/defer" }
        let(:withdrawal_url)    { "/api/v1/participants/npq/#{npq_application.user.id}/withdraw" }
        let(:params)            { { data: { attributes: { course_identifier: course_identifier, reason: Participants::Defer::NPQ.reasons.sample } } } }
        let(:withdrawal_params) { { data: { attributes: { course_identifier: course_identifier, reason: Participants::Withdraw::NPQ.reasons.sample } } } }
      end

      it_behaves_like "JSON Participant Resume endpoint", "npq-participant" do
        let(:course_identifier) { npq_course.identifier }
        let(:url)               { "/api/v1/participants/npq/#{npq_application.user.id}/resume" }
        let(:withdrawal_url)    { "/api/v1/participants/npq/#{npq_application.user.id}/withdraw" }
        let(:params)            { { data: { attributes: { course_identifier: course_identifier } } } }
        let(:withdrawal_params) { { data: { attributes: { course_identifier: course_identifier, reason: Participants::Withdraw::NPQ.reasons.sample } } } }
        before do
          put "/api/v1/participants/npq/#{npq_application.user.id}/defer",
              params: { data: { attributes: { course_identifier: course_identifier, reason: Participants::Defer::NPQ.reasons.sample } } }
        end
      end
    end

    context "when unauthorized" do
      it "returns 401 for invalid bearer token" do
        default_headers[:Authorization] = "Bearer ugLPicDrpGZdD_w7hhCL"
        get "/api/v1/participants/npq"
        expect(response.status).to eq 401
      end
    end

    context "when using a engage and learn token" do
      let(:token) { EngageAndLearnApiToken.create_with_random_token! }

      it "returns 401 for invalid bearer token" do
        default_headers[:Authorization] = bearer_token
        get "/api/v1/participants/npq"
        expect(response.status).to eq 403
      end
    end
  end

  describe "PUT /api/v1/participants/npq/:id/change-schedule", :with_default_schedules do
    let(:npq_application)         { create(:npq_application, :accepted, npq_lead_provider: npq_lead_provider) }
    let(:profile)                 { npq_application.profile }
    let(:new_schedule)            do
      if Finance::Schedule::NPQLeadership::IDENTIFIERS.include?(profile.npq_course.identifier)
        create(:npq_leadership_schedule, schedule_identifier: SecureRandom.alphanumeric)
      elsif Finance::Schedule::NPQSpecialist::IDENTIFIERS.include?(profile.npq_course.identifier)
        create(:npq_specialist_schedule, schedule_identifier: SecureRandom.alphanumeric)
      else
        create(:npq_aso_schedule, schedule_identifier: SecureRandom.alphanumeric)
      end
    end

    it "changes the schedules of the specified profile", :aggregate_failures do
      put "/api/v1/participants/npq/#{npq_application.profile.user_id}/change-schedule", params: {
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
end
