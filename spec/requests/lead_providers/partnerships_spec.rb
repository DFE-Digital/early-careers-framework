# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Lead provider partnerships spec", type: :request do
  let(:user) { create :user, :lead_provider }
  let(:cohort) { Cohort.current || create(:cohort, :current) }

  before do
    sign_in user
  end

  describe "GET /lead-providers/partnerships/:id" do
    context "when the current user belongs to the partnership's lead provider organisation" do
      let(:partnership) { create :partnership, cohort:, lead_provider: user.lead_provider }

      it "should show the partnership page" do
        get lead_providers_partnership_path(partnership)

        expect(response).to render_template :show
        expect(assigns(:partnership)).to eq partnership
      end
    end

    context "when the current user does not belong to the partnership's lead provider organisation" do
      let(:partnership) { create :partnership, cohort: }

      it "should show the partnership page" do
        expect { get lead_providers_partnership_path(partnership) }
          .to raise_error ActiveRecord::RecordNotFound
      end
    end
  end

  describe "GET /lead-providers/partnerships/active" do
    let(:parsed_response) { CSV.parse(response.body, headers: true) }

    let(:school) { create :school, name: "Active School" }
    let(:delivery_partner) { create :delivery_partner, name: "Active Delivery Partner" }

    let!(:partnership) { create :partnership, cohort:, lead_provider: user.lead_provider, school:, delivery_partner: }
    let!(:inactive_partnership) { create :partnership, :challenged, cohort:, lead_provider: user.lead_provider }

    before do
      get "/lead-providers/partnerships/active.csv"
    end

    it "returns the correct CSV content type header" do
      expect(response.headers["Content-Type"]).to include("text/csv")
    end

    it "returns a CSV file with the cohort start year in the filename" do
      expect(response.headers["Content-Disposition"]).to include "schools-#{cohort.start_year}.csv"
    end

    it "returns only active partnerships" do
      expect(parsed_response.length).to eql 1
    end

    it "returns the correct headers" do
      expect(parsed_response.headers).to match_array(%w[urn name delivery_partner])
    end

    it "returns the correct values" do
      school_row = parsed_response.find { |row| row["urn"] == school.urn }

      expect(school_row["name"]).to eq "Active School"
      expect(school_row["delivery_partner"]).to eq "Active Delivery Partner"
    end
  end
end
