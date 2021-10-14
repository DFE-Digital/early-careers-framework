# frozen_string_literal: true

require "rails_helper"

RSpec.describe "NPQ Participants API", type: :request, with_feature_flags: { participant_data_api: "active" } do
  describe "GET /api/v1/participants/npq" do
    let!(:default_schedule) { create(:schedule, :npq_specialist) }
    let(:npq_lead_provider) { create(:npq_lead_provider) }
    let(:cpd_lead_provider) { create(:cpd_lead_provider, npq_lead_provider: npq_lead_provider) }
    let(:token) { LeadProviderApiToken.create_with_random_token!(cpd_lead_provider: cpd_lead_provider) }
    let(:bearer_token) { "Bearer #{token}" }
    let(:npq_course) { create(:npq_course, identifier: "npq-senior-leadership") }

    context "when authorized" do
      before do
        default_headers[:Authorization] = bearer_token
      end

      before :each do
        list = create_list(:npq_application, 3, npq_lead_provider: npq_lead_provider, school_urn: "123456", npq_course: npq_course)

        list.each do |npq_application|
          NPQ::Accept.new(npq_application: npq_application).call
        end

        create_list(:npq_application, 3, npq_lead_provider: npq_lead_provider, school_urn: "123456", npq_course: npq_course)
      end

      describe "JSON Index API" do
        let(:parsed_response) { JSON.parse(response.body) }

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
          expect(parsed_response["data"][0]["id"]).to be_in(NPQApplication.pluck(:user_id))
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
            create_list(:npq_application, 2, npq_lead_provider: npq_lead_provider, updated_at: 10.days.ago, school_urn: "123456", npq_course: npq_course)
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
end
