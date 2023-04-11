# frozen_string_literal: true

require "rails_helper"

RSpec.describe "NPQ Participants API", :with_default_schedules, type: :request, with_feature_flags: { api_v3: "active" } do
  let(:token) { LeadProviderApiToken.create_with_random_token!(cpd_lead_provider:) }
  let(:bearer_token) { "Bearer #{token}" }
  let(:npq_lead_provider) { create(:npq_lead_provider) }
  let(:cpd_lead_provider) { create(:cpd_lead_provider, npq_lead_provider:) }
  let(:parsed_response) { JSON.parse(response.body) }

  before { default_headers[:Authorization] = bearer_token }

  describe "GET /api/v3/participants/npq" do
    let!(:npq_applications) do
      create_list(:npq_application, 3, :accepted, :with_started_declaration, npq_lead_provider:, school_urn: "123456")
    end

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

        it "returns IDs" do
          get "/api/v3/participants/npq"

          user = User.find(parsed_response["data"][0]["id"])
          expect(parsed_response["data"][0]["id"]).to be_in(ParticipantIdentity.joins(:npq_applications).pluck(:user_id))
          teacher_profile = user.teacher_profile

          expect(parsed_response["data"][0]["attributes"]["email"]).to eql(user.email)
          expect(parsed_response["data"][0]["attributes"]["full_name"]).to eql(user.full_name)
          expect(parsed_response["data"][0]["attributes"]["teacher_reference_number"]).to eql(teacher_profile.trn)
        end

        it "has correct attributes" do
          get "/api/v3/participants/npq"

          expect(parsed_response["data"][0])
            .to(have_jsonapi_attributes(
              :email,
              :full_name,
              :teacher_reference_number,
              :updated_at,
              :npq_enrolments,
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
              create_list(:npq_application, 3, :accepted, npq_lead_provider:, school_urn: "123456", npq_course:)
            end
          end

          it "returns content updated after specified timestamp" do
            get "/api/v3/participants/npq", params: { filter: { updated_since: 2.days.ago.iso8601 } }

            expect(parsed_response["data"].size).to eq(3)
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
end
