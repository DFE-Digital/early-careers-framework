# frozen_string_literal: true

require "rails_helper"

RSpec.describe "NPQ Participants API", type: :request, with_feature_flags: { participant_data_api: "active" } do
  describe "GET /api/v1/npq-participants" do
    let!(:default_schedule) { create(:schedule, name: "ECF September standard 2021") }
    let(:npq_lead_provider) { create(:npq_lead_provider) }
    let(:cpd_lead_provider) { create(:cpd_lead_provider, npq_lead_provider: npq_lead_provider) }
    let(:token) { LeadProviderApiToken.create_with_random_token!(cpd_lead_provider: cpd_lead_provider) }
    let(:bearer_token) { "Bearer #{token}" }

    context "when authorized" do
      before do
        default_headers[:Authorization] = bearer_token
      end

      before :each do
        list = []
        list << create_list(:npq_validation_data, 3, npq_lead_provider: npq_lead_provider, school_urn: "123456")

        list.flatten.each do |npq_validation_data|
          NPQ::CreateOrUpdateProfile.new(npq_validation_data: npq_validation_data).call
        end
      end

      describe "JSON Index API" do
        let(:parsed_response) { JSON.parse(response.body) }

        it "returns correct jsonapi content type header" do
          get "/api/v1/npq-participants"
          expect(response.headers["Content-Type"]).to eql("application/vnd.api+json")
        end

        it "returns all users" do
          get "/api/v1/npq-participants"
          expect(parsed_response["data"].size).to eql(3)
        end

        it "returns correct type" do
          get "/api/v1/npq-participants"
          expect(parsed_response["data"][0]).to have_type("npq-participant")
        end

        it "returns IDs" do
          get "/api/v1/npq-participants"
          expect(parsed_response["data"][0]["id"]).to be_in(NPQValidationData.pluck(:id))

          profile = NPQValidationData.find(parsed_response["data"][0]["id"])

          expect(parsed_response["data"][0]["attributes"]["date_of_birth"]).to eql(profile.date_of_birth.strftime("%F"))
          expect(parsed_response["data"][0]["attributes"]["teacher_reference_number"]).to eql(profile.teacher_reference_number)
          expect(parsed_response["data"][0]["attributes"]["teacher_reference_number_verified"]).to eql(profile.teacher_reference_number_verified)
          expect(parsed_response["data"][0]["attributes"]["active_alert"]).to eql(profile.active_alert)
          expect(parsed_response["data"][0]["attributes"]["school_ukprn"]).to eql(profile.school_ukprn)
          expect(parsed_response["data"][0]["attributes"]["school_ukprn"]).to eql(profile.school_ukprn)
          expect(parsed_response["data"][0]["attributes"]["headteacher_status"]).to eql(profile.headteacher_status)
          expect(parsed_response["data"][0]["attributes"]["eligible_for_funding"]).to eql(profile.eligible_for_funding)
          expect(parsed_response["data"][0]["attributes"]["headteacher_status"]).to eql(profile.headteacher_status)
          expect(parsed_response["data"][0]["attributes"]["eligible_for_funding"]).to eql(profile.eligible_for_funding)
          expect(parsed_response["data"][0]["attributes"]["funding_choice"]).to eql(profile.funding_choice)
        end

        it "has correct attributes" do
          get "/api/v1/npq-participants"
          expect(parsed_response["data"][0])
            .to(have_jsonapi_attributes(
              :participant_id,
              :date_of_birth,
              :teacher_reference_number,
              :teacher_reference_number_verified,
              :active_alert,
              :school_urn,
              :school_ukprn,
              :headteacher_status,
              :eligible_for_funding,
              :funding_choice,
            ).exactly)
        end

        it "can return paginated data" do
          get "/api/v1/npq-participants", params: { page: { per_page: 2, page: 1 } }
          expect(parsed_response["data"].size).to eql(2)

          get "/api/v1/npq-participants", params: { page: { per_page: 2, page: 2 } }
          expect(JSON.parse(response.body)["data"].size).to eql(1)
        end

        context "filtering" do
          before do
            create_list :npq_validation_data, 2, npq_lead_provider: npq_lead_provider, updated_at: 10.days.ago, school_urn: "123456"
          end

          it "returns content updated after specified timestamp" do
            get "/api/v1/npq-participants", params: { filter: { updated_since: 2.days.ago.iso8601 } }
            expect(parsed_response["data"].size).to eql(3)
          end

          context "with invalid filter of a string" do
            it "returns an error" do
              get "/api/v1/npq-participants", params: { filter: 2.days.ago.iso8601 }
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
        get "/api/v1/npq-participants"
        expect(response.status).to eq 401
      end
    end

    context "when using a engage and learn token" do
      let(:token) { EngageAndLearnApiToken.create_with_random_token! }

      it "returns 401 for invalid bearer token" do
        default_headers[:Authorization] = bearer_token
        get "/api/v1/npq-participants"
        expect(response.status).to eq 403
      end
    end
  end
end
