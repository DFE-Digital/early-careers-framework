# frozen_string_literal: true

require "rails_helper"
require "csv"

RSpec.describe "NPQ Enrolments API", type: :request do
  let(:token) { LeadProviderApiToken.create_with_random_token!(cpd_lead_provider:) }
  let(:bearer_token) { "Bearer #{token}" }
  let(:cpd_lead_provider) { create(:cpd_lead_provider, :with_npq_lead_provider) }
  let(:npq_lead_provider) { cpd_lead_provider.npq_lead_provider }

  before { default_headers[:Authorization] = bearer_token }

  let(:expected_headers) do
    %w[
      participant_id
      course_identifier
      schedule_identifier
      cohort
      npq_application_id
      eligible_for_funding
      training_status
      school_urn
    ]
  end

  describe "GET /api/v2/npq-enrolments.csv" do
    context "when authorized" do
      context "when there is no data" do
        it "returns csv headers and no rows" do
          get "/api/v2/npq-enrolments.csv"

          expect(response.status).to eql(200)

          rows = CSV.parse(response.body)

          expect(rows.size).to eql(1)
          expect(rows[0]).to eql(expected_headers)
        end
      end

      context "when there is data", :with_default_schedules do
        let!(:npq_profile) { create(:npq_participant_profile, npq_lead_provider:) }

        it "returns headers" do
          get "/api/v2/npq-enrolments.csv"
          rows = CSV.parse(response.body)
          expect(rows[0]).to eql(expected_headers)
        end

        it "returns correct data" do
          get "/api/v2/npq-enrolments.csv"
          rows = CSV.parse(response.body, headers: true)
          expect(rows.size).to eql(1)
          expect(rows[0].to_h.symbolize_keys).to eql(
            participant_id: npq_profile.user.id,
            course_identifier: npq_profile.npq_course.identifier,
            schedule_identifier: npq_profile.schedule.schedule_identifier,
            cohort: npq_profile.schedule.cohort.start_year.to_s,
            npq_application_id: npq_profile.npq_application.id,
            eligible_for_funding: npq_profile.npq_application.eligible_for_funding.to_s,
            training_status: npq_profile.training_status,
            school_urn: npq_profile.school_urn,
          )
        end

        context "with updated_since filter" do
          it "filters out results" do
            get "/api/v2/npq-enrolments.csv?filter[updated_since]=2030-11-13T11:21:55Z"
            rows = CSV.parse(response.body, headers: true)
            expect(rows.size).to eql(0)
          end
        end
      end
    end

    context "when unauthorized" do
      it "returns 401 for invalid bearer token" do
        default_headers[:Authorization] = "Bearer ugLPicDrpGZdD_w7hhCL"
        get "/api/v2/npq-enrolments.csv"
        expect(response.status).to eql(401)
      end
    end
  end
end
