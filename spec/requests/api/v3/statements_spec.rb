# frozen_string_literal: true

require "rails_helper"

RSpec.describe "statements endpoint spec", type: :request do
  let(:cpd_lead_provider) { create(:cpd_lead_provider) }
  let(:token) { LeadProviderApiToken.create_with_random_token!(cpd_lead_provider:) }
  let(:bearer_token) { "Bearer #{token}" }

  let(:current_cohort) { Cohort.current || create(:cohort, :current) }
  let(:next_cohort) { Cohort.next || create(:cohort, :next) }
  let!(:ecf_statement_current_cohort) do
    create(
      :ecf_statement,
      cpd_lead_provider:,
      cohort: current_cohort,
    )
  end
  let!(:ecf_statement_next_cohort) do
    create(
      :ecf_statement,
      cpd_lead_provider:,
      cohort: next_cohort,
    )
  end

  let(:parsed_response) { JSON.parse(response.body) }
  let(:params) { {} }

  describe "GET /statements" do
    before do
      default_headers[:Authorization] = bearer_token
      default_headers[:CONTENT_TYPE] = "application/json"
    end

    it "returns correct jsonapi content type header" do
      get("/api/v3/statements", params:)

      expect(response.headers["Content-Type"]).to eql("application/vnd.api+json")
    end

    it "returns a list of all statements" do
      get("/api/v3/statements", params:)
      expect(parsed_response["data"].count).to eq(2)
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
        :created_at,
        :updated_at,
        :cut_off_date,
        :payment_date,
        :paid,
      ).exactly
    end

    it "returns the right number of statements per page" do
      get "/api/v3/statements", params: { page: { per_page: 2, page: 1 } }

      expect(parsed_response["data"].size).to eql(2)
    end

    it "returns different statements for second page" do
      get "/api/v3/statements", params: { page: { per_page: 1, page: 2 } }

      expect(parsed_response["data"].size).to eql(1)
    end

    context "with cohort filter" do
      let(:params) { { filter: { cohort: current_cohort.display_name } } }
      it "returns statements within filter cohort" do
        get("/api/v3/statements", params:)

        expect(parsed_response["data"].size).to eql(1)
      end
    end

    context "with type filter" do
      let(:params) { { filter: { type: "ecf" } } }
      it "returns statements within filter type" do
        get("/api/v3/statements", params:)

        expect(parsed_response["data"].size).to eql(2)
      end
    end

    context "with updated_since filter" do
      before do
        ecf_statement_next_cohort.update!(updated_at: 3.days.ago)
        ecf_statement_current_cohort.update!(updated_at: 1.day.ago)
      end

      it "returns statements updated after updated_since" do
        get "/api/v3/statements", params: { filter: { updated_since: 2.days.ago.iso8601 } }

        expected_ids = [ecf_statement_current_cohort.id]
        expect(parsed_response["data"].size).to eql(1)
        expect(parsed_response["data"].map { |statement| statement["id"] }).to match_array expected_ids
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

  describe "GET /statements/:id" do
    let(:statement_id) { ecf_statement_next_cohort.id }

    before do
      default_headers[:Authorization] = bearer_token
      default_headers[:CONTENT_TYPE] = "application/json"
    end

    it "returns correct jsonapi content type header" do
      get("/api/v3/statements/#{statement_id}", params:)

      expect(response.headers["Content-Type"]).to eql("application/vnd.api+json")
    end

    it "returns statement with the corresponding id" do
      get("/api/v3/statements/#{statement_id}", params:)
      expect(parsed_response["data"]["id"]).to eq(statement_id)
    end

    it "returns correct type" do
      get("/api/v3/statements/#{statement_id}", params:)

      expect(parsed_response["data"]).to have_type("statement")
    end

    it "has correct attributes" do
      get("/api/v3/statements/#{statement_id}", params:)

      expect(parsed_response["data"]).to have_jsonapi_attributes(
        :month,
        :year,
        :type,
        :cohort,
        :created_at,
        :updated_at,
        :cut_off_date,
        :payment_date,
        :paid,
      ).exactly
    end

    context "when statement id is incorrect", exceptions_app: true do
      let(:statement_id) { "incorrect-id" }
      it "returns 404" do
        get("/api/v3/statements/#{statement_id}", params:)

        expect(response.status).to eq 404
      end
    end

    context "when unauthorized" do
      let(:token) { "incorrect-token" }
      it "returns 401" do
        get("/api/v3/statements/#{statement_id}", params:)

        expect(response.status).to eq 401
      end
    end
  end
end
