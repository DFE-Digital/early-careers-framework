# frozen_string_literal: true

require "rails_helper"

RSpec.describe "statements endpoint spec", type: :request do
  let(:cpd_lead_provider) { create(:cpd_lead_provider) }
  let(:token) { LeadProviderApiToken.create_with_random_token!(cpd_lead_provider:) }
  let(:bearer_token) { "Bearer #{token}" }

  let(:cohort_2021) { create(:cohort, :current) }
  let(:cohort_2022) { create(:cohort, :next) }
  let!(:ecf_statement_cohort_2022) do
    create(
      :ecf_statement,
      cpd_lead_provider:,
      cohort: cohort_2022,
    )
  end
  let!(:ecf_statement_cohort_2021) do
    create(
      :ecf_statement,
      cpd_lead_provider:,
      cohort: cohort_2021,
    )
  end
  let!(:npq_statement_cohort_2022) do
    create(
      :npq_statement,
      cpd_lead_provider:,
      cohort: cohort_2022,
    )
  end
  let!(:npq_statement_cohort_2021) do
    create(
      :npq_statement,
      cpd_lead_provider:,
      cohort: cohort_2021,
    )
  end

  let(:parsed_response) { JSON.parse(response.body) }
  let(:params) { {} }

  describe "GET /statements" do
    before do
      default_headers[:Authorization] = bearer_token
      default_headers[:CONTENT_TYPE] = "application/json"
    end

    context "with API V3 flag disabled" do
      it "returns a 404" do
        expect { get "/api/v3/statements", params: }.to raise_error(ActionController::RoutingError)
      end
    end

    context "with API V3 flag active", with_feature_flags: { api_v3: "active" } do
      it "returns correct jsonapi content type header" do
        get("/api/v3/statements", params:)

        expect(response.headers["Content-Type"]).to eql("application/vnd.api+json")
      end

      it "returns a list of all statements" do
        get("/api/v3/statements", params:)
        expect(parsed_response["data"].count).to eq(4)
      end

      it "returns correct type" do
        get("/api/v3/statements", params:)

        expect(parsed_response["data"][0]).to have_type("statement")
      end

      it "returns statement IDs" do
        get("/api/v3/statements", params:)

        expect(parsed_response["data"][0]["id"]).to be_in(Finance::Statement.pluck(:id))
      end

      it "has correct attributes" do
        get("/api/v3/statements", params:)

        expect(parsed_response["data"][0]).to have_jsonapi_attributes(
          :month,
          :year,
          :type,
          :cohort,
          :cut_off_date,
          :payment_date,
          :paid,
        ).exactly
      end

      it "returns the right number of statements per page" do
        get "/api/v3/statements", params: { page: { per_page: 3, page: 1 } }

        expect(parsed_response["data"].size).to eql(3)
      end

      it "returns different statements for second page" do
        get "/api/v3/statements", params: { page: { per_page: 3, page: 2 } }

        expect(parsed_response["data"].size).to eql(1)
      end

      context "with cohort filter" do
        let(:params) { { filter: { cohort: "2021" } } }
        it "returns statements within filter cohort" do
          get("/api/v3/statements", params:)

          expect(parsed_response["data"].size).to eql(2)
        end
      end

      context "with type filter" do
        let(:params) { { filter: { type: "ecf" } } }
        it "returns statements within filter type" do
          get("/api/v3/statements", params:)

          expect(parsed_response["data"].size).to eql(2)
        end
      end

      context "when unauthorized" do
        let(:token) { "incorrect-token" }
        it "returns 401" do
          get("/api/v3/statements", params:)

          expect(response.status).to eq 401
        end
      end
    end
  end
end
