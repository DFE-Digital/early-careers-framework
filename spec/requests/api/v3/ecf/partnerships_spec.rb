# frozen_string_literal: true

require "rails_helper"

RSpec.describe "API ECF Partnerships", type: :request do
  let(:cpd_lead_provider) { create(:cpd_lead_provider, :with_lead_provider) }
  let(:lead_provider) { cpd_lead_provider.lead_provider }
  let(:cohort) { Cohort.current || create(:cohort, :current) }
  let(:delivery_partner) { create(:delivery_partner, name: "First Delivery Partner") }
  let(:school) { create(:school, urn: "123456", name: "My first High School") }
  let(:token) { LeadProviderApiToken.create_with_random_token!(cpd_lead_provider:) }
  let(:bearer_token) { "Bearer #{token}" }
  let(:parsed_response) { JSON.parse(response.body) }

  let!(:another_cohort) { create(:cohort, start_year: "2050") }

  describe "#index" do
    let!(:partnership) { create(:partnership, school:, cohort:, delivery_partner:, lead_provider:) }

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

        expect(parsed_response["data"][0]).to have_type("partnership")
      end

      it "returns IDs" do
        get "/api/v3/partnerships/ecf"

        expect(parsed_response["data"][0]["id"]).to be_in(Partnership.pluck(:id))
      end

      it "has correct attributes" do
        get "/api/v3/partnerships/ecf"

        expect(parsed_response["data"][0]).to have_jsonapi_attributes(
          :cohort,
          :urn,
          :delivery_partner_id,
          :delivery_partner_name,
          :school_id,
          :status,
          :challenged_at,
          :challenged_reason,
          :induction_tutor_name,
          :induction_tutor_email,
          :updated_at,
          :created_at,
        ).exactly
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

      describe "ordering" do
        context "when ordering by updated_at ascending" do
          let(:sort_param) { "updated_at" }

          before { get "/api/v3/partnerships/ecf", params: { sort: sort_param, filter: { cohort: [cohort.display_name, another_cohort.display_name].join(",") } } }

          it "returns an ordered list of partnership" do
            expect(parsed_response["data"].size).to eql(2)
            expect(parsed_response.dig("data", 0, "attributes", "delivery_partner_name")).to eql("First Delivery Partner")
            expect(parsed_response.dig("data", 1, "attributes", "delivery_partner_name")).to eql("Second Delivery Partner")
          end
        end

        context "when ordering by updated_at descending" do
          let(:sort_param) { "-updated_at" }

          before { get "/api/v3/partnerships/ecf", params: { sort: sort_param, filter: { cohort: [cohort.display_name, another_cohort.display_name].join(",") } } }

          it "returns an ordered list of partnership" do
            expect(parsed_response["data"].size).to eql(2)
            expect(parsed_response.dig("data", 0, "attributes", "delivery_partner_name")).to eql("Second Delivery Partner")
            expect(parsed_response.dig("data", 1, "attributes", "delivery_partner_name")).to eql("First Delivery Partner")
          end
        end

        context "when not including sort in the params" do
          before do
            partnership.update!(created_at: 10.days.ago)

            get "/api/v3/partnerships/ecf", params: { sort: "", filter: { cohort: [cohort.display_name, another_cohort.display_name].join(",") } }
          end

          it "returns all records ordered by created_at" do
            expect(parsed_response["data"].size).to eql(2)
            expect(parsed_response.dig("data", 0, "attributes", "delivery_partner_name")).to eql("First Delivery Partner")
            expect(parsed_response.dig("data", 1, "attributes", "delivery_partner_name")).to eql("Second Delivery Partner")
          end
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

  describe "GET /api/v3/partnerships/ecf/:id" do
    let!(:partnership) { create(:partnership, school:, cohort:, delivery_partner:, lead_provider:) }
    let(:partnership_id) { partnership.id }

    before do
      default_headers[:Authorization] = bearer_token
      default_headers[:CONTENT_TYPE] = "application/json"
      get("/api/v3/partnerships/ecf/#{partnership_id}")
    end

    it "returns correct jsonapi content type header" do
      expect(response.headers["Content-Type"]).to eql("application/vnd.api+json")
    end

    it "returns partnership with the corresponding id" do
      expect(parsed_response["data"]["id"]).to eq(partnership_id)
    end

    it "returns correct type" do
      expect(parsed_response["data"]).to have_type("partnership")
    end

    it "has correct attributes" do
      expect(parsed_response["data"]).to have_jsonapi_attributes(
        :cohort,
        :urn,
        :delivery_partner_id,
        :delivery_partner_name,
        :school_id,
        :status,
        :challenged_at,
        :challenged_reason,
        :induction_tutor_name,
        :induction_tutor_email,
        :updated_at,
        :created_at,
      ).exactly
    end

    context "when partnership id is incorrect", exceptions_app: true do
      let(:partnership_id) { "incorrect-id" }

      it "returns 404" do
        expect(response.status).to eq 404
      end
    end

    context "when unauthorized" do
      let(:token) { "incorrect-token" }

      it "returns 401" do
        expect(response.status).to eq 401
      end
    end
  end

  describe "POST /api/v3/partnerships/ecf" do
    let!(:provider_relationship) { create(:provider_relationship, lead_provider:, delivery_partner:, cohort:) }

    let(:params_hash) do
      {
        cohort: cohort.start_year,
        school_id: school.id,
        delivery_partner_id: delivery_partner.id,
      }
    end

    let(:params_json) do
      {
        data: {
          type: "ecf-partnership",
          attributes: params_hash,
        },
      }.to_json
    end

    before do
      default_headers[:Authorization] = bearer_token
      default_headers[:CONTENT_TYPE] = "application/json"
    end

    context "when unauthorized" do
      let(:token) { "incorrect-token" }

      it "returns 401" do
        post("/api/v3/partnerships/ecf", params: params_json)

        expect(response.status).to eq 401
      end
    end

    context "valid params" do
      it "creates a new partnership" do
        expect(Partnership.count).to eql(0)
        post("/api/v3/partnerships/ecf", params: params_json)

        expect(response.headers["Content-Type"]).to eql("application/vnd.api+json")
        expect(response.status).to eq 200

        expect(parsed_response["data"]).to have_type("partnership")
        expect(parsed_response["data"]).to have_jsonapi_attributes(
          :cohort,
          :urn,
          :delivery_partner_id,
          :delivery_partner_name,
          :school_id,
          :status,
          :challenged_at,
          :challenged_reason,
          :induction_tutor_name,
          :induction_tutor_email,
          :updated_at,
          :created_at,
        ).exactly

        expect(parsed_response["data"]["attributes"]["cohort"]).to eq(cohort.start_year.to_s)
        expect(parsed_response["data"]["attributes"]["delivery_partner_id"]).to eq(delivery_partner.id)
        expect(parsed_response["data"]["attributes"]["school_id"]).to eq(school.id)

        expect(Partnership.count).to eql(1)
        partnership = Partnership.first
        expect(partnership.cohort_id).to eq(cohort.id)
        expect(partnership.delivery_partner_id).to eq(delivery_partner.id)
        expect(partnership.school_id).to eq(school.id)
      end
    end

    context "missing params" do
      let(:params_hash) do
        {
          cohort: nil,
          school_id: nil,
          delivery_partner_id: nil,
        }
      end

      it "returns errors" do
        expect(Partnership.count).to eql(0)
        post("/api/v3/partnerships/ecf", params: params_json)

        expect(response.headers["Content-Type"]).to eql("application/vnd.api+json")
        expect(response.status).to eq 422

        errors = parsed_response["errors"].each_with_object({}) do |er, sum|
          sum[er["title"]] = er["detail"]
        end
        expect(errors["cohort"]).to include("The attribute '#/cohort' must be included as part of partnership confirmations.")
        expect(errors["school_id"]).to include("The attribute '#/school_id' must be included as part of partnership confirmations.")
        expect(errors["delivery_partner_id"]).to include("The attribute '#/delivery_partner_id' must be included as part of partnership confirmations.")
        expect(Partnership.count).to eql(0)
      end
    end
  end

  describe "PUT /api/v3/partnerships/ecf/:id" do
    let(:delivery_partner2) { create(:delivery_partner, name: "Second Delivery Partner") }
    let!(:provider_relationship2) { create(:provider_relationship, lead_provider:, delivery_partner: delivery_partner2, cohort:) }
    let!(:partnership) { create(:partnership, school:, cohort:, delivery_partner:, lead_provider:) }
    let(:partnership_id) { partnership.id }

    let(:params_hash) do
      {
        delivery_partner_id: delivery_partner2.id,
      }
    end

    let(:params_json) do
      {
        data: {
          type: "ecf-partnership-update",
          attributes: params_hash,
        },
      }.to_json
    end

    before do
      default_headers[:Authorization] = bearer_token
      default_headers[:CONTENT_TYPE] = "application/json"
    end

    context "when unauthorized" do
      let(:token) { "incorrect-token" }

      it "returns 401" do
        put("/api/v3/partnerships/ecf/#{partnership_id}", params: params_json)

        expect(response.status).to eq 401
      end
    end

    context "when partnership id is incorrect", exceptions_app: true do
      let(:partnership_id) { "incorrect-id" }

      it "returns 404" do
        put("/api/v3/partnerships/ecf/#{partnership_id}", params: params_json)

        expect(response.status).to eq 404
      end
    end

    context "missing params" do
      let(:params_hash) do
        {
          delivery_partner_id: nil,
        }
      end

      it "returns errors" do
        expect(Partnership.count).to eql(1)
        put("/api/v3/partnerships/ecf/#{partnership_id}", params: params_json)

        expect(response.headers["Content-Type"]).to eql("application/vnd.api+json")
        expect(response.status).to eq 422

        errors = parsed_response["errors"].each_with_object({}) do |er, sum|
          sum[er["title"]] = er["detail"]
        end
        expect(errors["delivery_partner_id"]).to include("The attribute '#/delivery_partner_id' must be included as part of partnership confirmations.")
        expect(Partnership.count).to eql(1)
      end
    end

    context "valid params" do
      it "updates a partnership" do
        expect(Partnership.count).to eql(1)
        put("/api/v3/partnerships/ecf/#{partnership_id}", params: params_json)

        expect(response.headers["Content-Type"]).to eql("application/vnd.api+json")
        expect(response.status).to eq 200

        expect(parsed_response["data"]).to have_type("partnership")
        expect(parsed_response["data"]).to have_jsonapi_attributes(
          :cohort,
          :urn,
          :delivery_partner_id,
          :delivery_partner_name,
          :school_id,
          :status,
          :challenged_at,
          :challenged_reason,
          :induction_tutor_name,
          :induction_tutor_email,
          :updated_at,
          :created_at,
        ).exactly

        expect(parsed_response["data"]["attributes"]["cohort"]).to eq(cohort.start_year.to_s)
        expect(parsed_response["data"]["attributes"]["school_id"]).to eq(school.id)
        expect(parsed_response["data"]["attributes"]["delivery_partner_id"]).to eq(delivery_partner2.id)

        expect(Partnership.count).to eql(1)
        part = Partnership.first
        expect(part.id).to eq(partnership_id)
        expect(part.cohort_id).to eq(cohort.id)
        expect(part.school_id).to eq(school.id)
        expect(part.delivery_partner_id).to eq(delivery_partner2.id)
      end
    end
  end
end
