# frozen_string_literal: true

require "rails_helper"
require "csv"

RSpec.describe "NPQ Applications API", type: :request, with_feature_flags: { participant_data_api: "active" } do
  describe "GET /api/v1/npq-applications" do
    let(:cpd_lead_provider) { create(:cpd_lead_provider, npq_lead_provider: npq_lead_provider) }
    let(:npq_lead_provider) { create(:npq_lead_provider) }
    let(:other_npq_lead_provider) { create(:npq_lead_provider) }
    let(:token) { LeadProviderApiToken.create_with_random_token!(cpd_lead_provider: cpd_lead_provider) }
    let(:bearer_token) { "Bearer #{token}" }
    let!(:school) { create(:school, urn: "123456") }
    let!(:cohort) { create(:cohort, :current) }

    before :each do
      create_list :npq_validation_data, 3, npq_lead_provider: npq_lead_provider, school_urn: "123456"
      create_list :npq_validation_data, 2, npq_lead_provider: other_npq_lead_provider, school_urn: "123456"
    end

    context "when authorized" do
      before do
        default_headers[:Authorization] = bearer_token
      end

      describe "JSON API" do
        let(:parsed_response) { JSON.parse(response.body) }

        it "returns correct jsonapi content type header" do
          get "/api/v1/npq-applications"
          expect(response.headers["Content-Type"]).to eql("application/vnd.api+json")
        end

        it "returns scoped profiles" do
          get "/api/v1/npq-applications"
          expect(parsed_response["data"].size).to eql(3)
        end

        it "returns correct type" do
          get "/api/v1/npq-applications"
          expect(parsed_response["data"][0]).to have_type("npq_application")
        end

        it "returns correct data" do
          get "/api/v1/npq-applications"

          expect(parsed_response["data"][0]["id"]).to be_in(NPQValidationData.pluck(:id))

          profile = NPQValidationData.find(parsed_response["data"][0]["id"])
          user = User.find(parsed_response["data"][0]["attributes"]["participant_id"])

          expect(parsed_response["data"][0]["attributes"]["full_name"]).to eql(user.full_name)

          expect(parsed_response["data"][0]["attributes"]["email"]).to eql(user.email)
          expect(parsed_response["data"][0]["attributes"]["email_validated"]).to eql(true)

          expect(parsed_response["data"][0]["attributes"]["school_urn"]).to eql(profile.school_urn)

          expect(parsed_response["data"][0]["attributes"]["teacher_reference_number"]).to eql(profile.teacher_reference_number)
          expect(parsed_response["data"][0]["attributes"]["teacher_reference_number_validated"]).to eql(profile.teacher_reference_number_verified)

          expect(parsed_response["data"][0]["attributes"]["eligible_for_funding"]).to eql(profile.eligible_for_funding)

          expect(parsed_response["data"][0]["attributes"]["course_id"]).to eql(profile.npq_course_id)
          expect(parsed_response["data"][0]["attributes"]["course_name"]).to eql(profile.npq_course.name)
        end

        it "can return paginated data" do
          get "/api/v1/npq-applications", params: { page: { per_page: 2, page: 1 } }
          expect(parsed_response["data"].size).to eql(2)

          get "/api/v1/npq-applications", params: { page: { per_page: 2, page: 2 } }
          expect(JSON.parse(response.body)["data"].size).to eql(1)
        end

        context "filtering" do
          before do
            create_list :npq_validation_data, 2, npq_lead_provider: npq_lead_provider, updated_at: 10.days.ago, school_urn: "123456"
          end

          it "returns content updated after specified timestamp" do
            get "/api/v1/npq-applications", params: { filter: { updated_since: 2.days.ago.iso8601 } }
            expect(parsed_response["data"].size).to eql(3)
          end
        end
      end

      describe "CSV API" do
        let(:parsed_response) { CSV.parse(response.body, headers: true) }

        before do
          get "/api/v1/npq-applications.csv"
        end

        it "returns the correct CSV content type header" do
          expect(response.headers["Content-Type"]).to eql("text/csv")
        end

        it "returns scoped profiles" do
          expect(parsed_response.length).to eql(NPQValidationData.where(npq_lead_provider: npq_lead_provider).count)
        end

        it "returns the correct headers" do
          expect(parsed_response.headers).to match_array(
            %w[
              id
              participant_id
              full_name
              email
              email_validated
              teacher_reference_number
              teacher_reference_number_validated
              school_urn
              headteacher_status
              eligible_for_funding
              funding_choice
              course_id
              course_name
            ],
          )
        end
      end
    end

    context "when unauthorized" do
      it "returns 401 for invalid bearer token" do
        default_headers[:Authorization] = "Bearer ugLPicDrpGZdD_w7hhCL"
        get "/api/v1/npq-applications"
        expect(response.status).to eq 401
      end
    end

    context "when token belongs to provider that does not handle NPQs" do
      let(:cpd_lead_provider) { create(:cpd_lead_provider, lead_provider: lead_provider) }
      let(:lead_provider) { create(:lead_provider) }
      let(:token) { LeadProviderApiToken.create_with_random_token!(cpd_lead_provider: cpd_lead_provider) }
      let(:bearer_token) { "Bearer #{token}" }

      it "returns 403" do
        default_headers[:Authorization] = bearer_token
        get "/api/v1/npq-applications"
        expect(response.status).to eq 403
      end
    end

    context "when using a engage and learn token" do
      let(:token) { EngageAndLearnApiToken.create_with_random_token! }

      it "returns 401 for invalid bearer token" do
        default_headers[:Authorization] = bearer_token
        get "/api/v1/npq-applications"
        expect(response.status).to eq 403
      end
    end
  end
end

RSpec.describe "NPQ Applications API without feature flag", type: :request do
  describe "GET /api/v1/npq-applications" do
    it "does not route" do
      expect {
        get "/api/v1/npq-applications"
      }.to raise_error(ActionController::RoutingError)
    end
  end
end
