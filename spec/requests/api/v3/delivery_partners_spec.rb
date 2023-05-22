# frozen_string_literal: true

require "rails_helper"

RSpec.describe "API Delivery Partners", :with_default_schedules, type: :request, with_feature_flags: { api_v3: "active" } do
  let(:cpd_lead_provider) { create(:cpd_lead_provider, :with_lead_provider) }
  let(:lead_provider) { cpd_lead_provider.lead_provider }
  let(:cohort) { Cohort.current || create(:cohort, :current) }
  let(:delivery_partner) { create(:delivery_partner, name: "First Delivery Partner") }
  let!(:provider_relationship) { create(:provider_relationship, cohort:, delivery_partner:, lead_provider:) }
  let(:token) { LeadProviderApiToken.create_with_random_token!(cpd_lead_provider:) }
  let(:bearer_token) { "Bearer #{token}" }
  let(:parsed_response) { JSON.parse(response.body) }

  describe "#index" do
    before :each do
      @another_delivery_partner = create(:delivery_partner, name: "Second Delivery Partner")
      @another_cohort = create(:cohort, start_year: "2050")
      create(:provider_relationship, cohort: @another_cohort, delivery_partner: @another_delivery_partner, lead_provider:)
    end

    context "when authorized" do
      before do
        default_headers[:Authorization] = bearer_token
      end

      it "returns correct jsonapi content type header" do
        get "/api/v3/delivery-partners"

        expect(response.headers["Content-Type"]).to eq("application/vnd.api+json")
      end

      it "returns all delivery partners" do
        get "/api/v3/delivery-partners"

        expect(parsed_response["data"].size).to eql(DeliveryPartner.count)
      end

      it "returns correct type" do
        get "/api/v3/delivery-partners"

        expect(parsed_response["data"][0]).to have_type("delivery-partner")
      end

      it "returns IDs" do
        get "/api/v3/delivery-partners"

        expect(parsed_response["data"][0]["id"]).to be_in(DeliveryPartner.pluck(:id))
      end

      it "has correct attributes" do
        get "/api/v3/delivery-partners"

        expect(parsed_response["data"][0]).to have_jsonapi_attributes(:name, :created_at, :updated_at, :cohort).exactly
      end

      it "returns the right number of delivery partners per page" do
        get "/api/v3/delivery-partners", params: { page: { per_page: 1, page: 1 } }

        expect(parsed_response["data"].size).to eql(1)
      end

      context "when filtering by cohort" do
        it "returns all delivery partners that match" do
          get "/api/v3/delivery-partners", params: { filter: { cohort: [cohort.start_year, 2050].join(",") } }

          expect(parsed_response["data"].size).to eql(2)
        end

        it "returns all delivery partners that match" do
          get "/api/v3/delivery-partners", params: { filter: { cohort: "2050" } }

          expect(parsed_response["data"].size).to eql(1)
          expect(parsed_response.dig("data", 0, "attributes", "name")).to eql("Second Delivery Partner")
        end

        it "returns no delivery partners if no matches" do
          get "/api/v3/delivery-partners", params: { filter: { cohort: "3100" } }

          expect(parsed_response["data"].size).to eql(0)
        end
      end

      context "when ordering by name" do
        it "returns an ordered list of delivery partners" do
          get "/api/v3/delivery-partners", params: { sort: "-name" }

          expect(parsed_response["data"].size).to eql(2)
          expect(parsed_response.dig("data", 0, "attributes", "name")).to eql("Second Delivery Partner")
          expect(parsed_response.dig("data", 1, "attributes", "name")).to eql("First Delivery Partner")
        end

        it "returns an ordered list of delivery partners" do
          get "/api/v3/delivery-partners", params: { sort: "name,-updated_at" }

          expect(parsed_response["data"].size).to eql(2)
          expect(parsed_response.dig("data", 0, "attributes", "name")).to eql("First Delivery Partner")
          expect(parsed_response.dig("data", 1, "attributes", "name")).to eql("Second Delivery Partner")
        end

        it "returns an ordered list of delivery partners" do
          get "/api/v3/delivery-partners", params: { sort: "-updated_at,name" }

          expect(parsed_response["data"].size).to eql(2)
          expect(parsed_response.dig("data", 0, "attributes", "name")).to eql("Second Delivery Partner")
          expect(parsed_response.dig("data", 1, "attributes", "name")).to eql("First Delivery Partner")
        end
      end

      context "when not including sort in the params" do
        before do
          @another_delivery_partner.update!(created_at: 10.days.ago)

          get "/api/v3/delivery-partners", params: { sort: "" }
        end

        it "returns all records ordered by npq applications created_at" do
          expect(parsed_response["data"].size).to eql(2)
          expect(parsed_response.dig("data", 0, "attributes", "name")).to eql("Second Delivery Partner")
          expect(parsed_response.dig("data", 1, "attributes", "name")).to eql("First Delivery Partner")
        end
      end
    end

    context "when unauthorized" do
      it "returns 401 for invalid bearer token" do
        default_headers[:Authorization] = "Bearer ugLPicDrpGZdD_w7hhCL"
        get "/api/v3/delivery-partners"

        expect(response.status).to eq(401)
      end
    end

    context "when using a engage and learn token" do
      let(:token) { EngageAndLearnApiToken.create_with_random_token! }

      it "returns 403 for invalid bearer token" do
        default_headers[:Authorization] = bearer_token
        get "/api/v3/delivery-partners"

        expect(response.status).to eq(403)
      end
    end
  end

  describe "#show" do
    context "when authorized" do
      before do
        default_headers[:Authorization] = bearer_token
      end

      it "returns correct jsonapi content type header" do
        get "/api/v3/delivery-partners/#{delivery_partner.id}"

        expect(response.headers["Content-Type"]).to eq("application/vnd.api+json")
      end

      it "returns a specific delivery partner" do
        get "/api/v3/delivery-partners/#{delivery_partner.id}"

        expect(parsed_response["data"]["id"]).to be_in(DeliveryPartner.pluck(:id))
      end

      it "returns correct type" do
        get "/api/v3/delivery-partners/#{delivery_partner.id}"

        expect(parsed_response["data"]).to have_type("delivery-partner")
      end

      it "returns ID" do
        get "/api/v3/delivery-partners/#{delivery_partner.id}"

        expect(parsed_response["data"]["id"]).to be_in(DeliveryPartner.pluck(:id))
      end

      it "has correct attributes" do
        get "/api/v3/delivery-partners/#{delivery_partner.id}"

        expect(parsed_response["data"]).to have_jsonapi_attributes(:name, :created_at, :updated_at, :cohort).exactly
      end
    end

    context "when unauthorized" do
      it "returns 401 for invalid bearer token" do
        default_headers[:Authorization] = "Bearer ugLPicDrpGZdD_w7hhCL"
        get "/api/v3/delivery-partners/#{delivery_partner.id}"

        expect(response.status).to eq(401)
      end
    end

    context "when using a engage and learn token" do
      let(:token) { EngageAndLearnApiToken.create_with_random_token! }

      it "returns 403 for invalid bearer token" do
        default_headers[:Authorization] = bearer_token
        get "/api/v3/delivery-partners/#{delivery_partner.id}"

        expect(response.status).to eq(403)
      end
    end
  end
end
