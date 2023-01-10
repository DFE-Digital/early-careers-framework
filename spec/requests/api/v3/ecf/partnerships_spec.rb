# frozen_string_literal: true

require "rails_helper"

RSpec.describe "API ECF Partinerships", :with_default_schedules, type: :request, with_feature_flags: { api_v3: "active" } do
  let(:cpd_lead_provider) { create(:cpd_lead_provider, :with_lead_provider) }
  let(:lead_provider) { cpd_lead_provider.lead_provider }
  let(:cohort) { Cohort.current || create(:cohort, :current) }
  let(:delivery_partner) { create(:delivery_partner, name: "First Delivery Partner") }
  let(:school) { create(:school, urn: "123456", name: "My first High School") }
  let!(:partnership) { create(:partnership, school:, cohort:, delivery_partner:, lead_provider:) }
  let(:token) { LeadProviderApiToken.create_with_random_token!(cpd_lead_provider:) }
  let(:bearer_token) { "Bearer #{token}" }
  let(:parsed_response) { JSON.parse(response.body) }

  let!(:another_cohort) { create(:cohort, start_year: "2050") }

  describe "#index" do
    before do
      another_delivery_partner = create(:delivery_partner, name: "Second Delivery Partner")
      create(:partnership, school:, cohort: another_cohort, delivery_partner: another_delivery_partner, lead_provider:)
    end

    context "when authorized" do
      before do
        default_headers[:Authorization] = bearer_token
      end

      it "returns correct jsonapi content type header" do
        get "/api/v3/partnerships/ecf"

        expect(response.headers["Content-Type"]).to eq("application/vnd.api+json")
      end

      it "returns all partnerships" do
        get "/api/v3/partnerships/ecf"

        expect(parsed_response["data"].size).to eql(Partnership.count)
      end

      it "returns correct type" do
        get "/api/v3/partnerships/ecf"

        expect(parsed_response["data"][0]).to have_type("partnership-confirmation")
      end

      it "returns IDs" do
        get "/api/v3/partnerships/ecf"

        expect(parsed_response["data"][0]["id"]).to be_in(Partnership.pluck(:id))
      end

      it "has correct attributes" do
        get "/api/v3/partnerships/ecf"

        expect(parsed_response["data"][0]).to have_jsonapi_attributes(:cohort,
                                                                      :urn,
                                                                      :delivery_partner_id,
                                                                      :delivery_partner_name,
                                                                      :status, :challenged_reason, :induction_tutor_name, :induction_tutor_email, :updated_at, :created_at).exactly
      end

      it "returns the right number of partnerships per page" do
        get "/api/v3/partnerships/ecf", params: { page: { per_page: 1, page: 1 } }

        expect(parsed_response["data"].size).to eql(1)
      end

      context "when filtering by cohort" do
        it "returns all partnerships that match" do
          get "/api/v3/partnerships/ecf", params: { filter: { cohort: [cohort.display_name, another_cohort.display_name].join(",") } }

          expect(parsed_response["data"].size).to eql(2)
        end

        it "returns all partnerships that match" do
          get "/api/v3/partnerships/ecf", params: { filter: { cohort: "2050" } }

          expect(parsed_response["data"].size).to eql(1)
          expect(parsed_response.dig("data", 0, "attributes", "delivery_partner_name")).to eql("Second Delivery Partner")
        end

        it "returns no partnerships if no matches" do
          get "/api/v3/partnerships/ecf", params: { filter: { cohort: "3100" } }

          expect(parsed_response["data"].size).to eql(0)
        end
      end

      context "when ordering by name" do
        it "returns an ordered list of partnership" do
          get "/api/v3/partnerships/ecf", params: { sort: "updated_at" }

          expect(parsed_response["data"].size).to eql(2)
          expect(parsed_response.dig("data", 0, "attributes", "delivery_partner_name")).to eql("First Delivery Partner")
          expect(parsed_response.dig("data", 1, "attributes", "delivery_partner_name")).to eql("Second Delivery Partner")
        end

        it "returns an ordered list of partnership" do
          get "/api/v3/partnerships/ecf", params: { sort: "-updated_at" }

          expect(parsed_response["data"].size).to eql(2)
          expect(parsed_response.dig("data", 0, "attributes", "delivery_partner_name")).to eql("Second Delivery Partner")
          expect(parsed_response.dig("data", 1, "attributes", "delivery_partner_name")).to eql("First Delivery Partner")
        end
      end
    end

    context "when unauthorized" do
      it "returns 401 for invalid bearer token" do
        default_headers[:Authorization] = "Bearer ugLPicDrpGZdD_w7hhCL"
        get "/api/v3/partnerships/ecf"

        expect(response.status).to eq(401)
      end
    end

    context "when using a engage and learn token" do
      let(:token) { EngageAndLearnApiToken.create_with_random_token! }

      it "returns 403 for invalid bearer token" do
        default_headers[:Authorization] = bearer_token
        get "/api/v3/partnerships/ecf"

        expect(response.status).to eq(403)
      end
    end
  end
end
