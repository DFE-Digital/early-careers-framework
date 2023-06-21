# frozen_string_literal: true

require "rails_helper"

RSpec.describe "API ECF transfers", :with_default_schedules, type: :request do
  let(:cpd_lead_provider) { create(:cpd_lead_provider, :with_lead_provider) }
  let(:token) { LeadProviderApiToken.create_with_random_token!(cpd_lead_provider:) }
  let(:bearer_token) { "Bearer #{token}" }
  let(:parsed_response) { JSON.parse(response.body) }

  before { default_headers[:Authorization] = bearer_token }

  describe "GET /api/v3/participants/ecf/transfers" do
    context "when authorized" do
      let!(:transfer) do
        NewSeeds::Scenarios::Participants::Transfers::FipToFipKeepingOriginalTrainingProvider
          .new(lead_provider_from: cpd_lead_provider.lead_provider)
          .build
      end

      describe "JSON Index API" do
        it "returns correct jsonapi content type header" do
          get "/api/v3/participants/ecf/transfers"
          expect(response.headers["Content-Type"]).to eql("application/vnd.api+json")
        end

        it "returns all transferred users" do
          get "/api/v3/participants/ecf/transfers"
          expect(parsed_response["data"].size).to eql(1)
        end

        it "returns correct type" do
          get "/api/v3/participants/ecf/transfers"
          expect(parsed_response["data"][0]).to have_type("participant-transfer")
        end

        it "has correct attributes" do
          get "/api/v3/participants/ecf/transfers"
          expect(parsed_response["data"][0])
            .to(have_jsonapi_attributes(
              :updated_at,
              :transfers,
            ).exactly)
        end

        it "returns the correct participant transfers" do
          get "/api/v3/participants/ecf/transfers"
          expect(parsed_response["data"][0]["attributes"]["transfers"].size).to eq(1)
        end

        context "pagination" do
          let!(:another_transfer) do
            NewSeeds::Scenarios::Participants::Transfers::FipToFipKeepingOriginalTrainingProvider
              .new(lead_provider_from: cpd_lead_provider.lead_provider)
              .build
          end

          it "can return paginated data" do
            get "/api/v3/participants/ecf/transfers", params: { page: { per_page: 1, page: 1 } }
            expect(parsed_response["data"].size).to eql(1)

            get "/api/v3/participants/ecf/transfers", params: { page: { per_page: 1, page: 2 } }
            expect(JSON.parse(response.body)["data"].size).to eql(1)
          end
        end

        context "filtering" do
          let!(:another_transfer) do
            travel_to 10.days.ago do
              NewSeeds::Scenarios::Participants::Transfers::FipToFipKeepingOriginalTrainingProvider
                .new(lead_provider_from: cpd_lead_provider.lead_provider)
                .build
            end
          end

          it "returns content updated after specified timestamp" do
            get "/api/v3/participants/ecf/transfers", params: { filter: { updated_since: 2.days.ago.iso8601 } }

            expect(parsed_response["data"].size).to eq(1)
          end

          context "with invalid filter of a string" do
            it "returns an error" do
              get "/api/v3/participants/ecf/transfers", params: { filter: 2.days.ago.iso8601 }
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
        get "/api/v3/participants/ecf/transfers"
        expect(response.status).to eq 401
      end
    end

    context "when using a engage and learn token" do
      let(:token) { EngageAndLearnApiToken.create_with_random_token! }

      it "returns 401 for invalid bearer token" do
        default_headers[:Authorization] = bearer_token
        get "/api/v3/participants/ecf/transfers"
        expect(response.status).to eq 403
      end
    end
  end

  describe "GET /api/v3/participants/ecf/:id/transfers" do
    let!(:transfer) do
      NewSeeds::Scenarios::Participants::Transfers::FipToFipKeepingOriginalTrainingProvider
        .new(lead_provider_from: cpd_lead_provider.lead_provider)
        .build
    end
    let(:user) { transfer.preferred_identity.user }

    before do
      get "/api/v3/participants/ecf/#{user.id}/transfers"
    end

    context "when authorized" do
      it "returns correct jsonapi content type header" do
        expect(response.headers["Content-Type"]).to eql("application/vnd.api+json")
      end

      it "returns correct type" do
        expect(parsed_response["data"]).to have_type("participant-transfer")
      end

      it "has correct attributes" do
        expect(parsed_response["data"])
          .to(have_jsonapi_attributes(
            :updated_at,
            :transfers,
          ).exactly)
      end

      it "returns the correct participant transfers" do
        expect(parsed_response["data"]["attributes"]["transfers"].size).to eq(1)
      end
    end

    context "when unauthorized" do
      let(:token) { "wrong_token" }

      it "returns 401 for invalid bearer token" do
        expect(response.status).to eq 401
      end
    end
  end
end
