# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Lead Provider landing page", type: :request do
  describe "GET /lead-providers" do
    it "should show the Lead Provider landing page" do
      get lead_providers_landing_page_path

      expect(response).to render_template :index
      expect(response.body).to include("Manage your records quickly and easily")
    end

    it "should sign post visitors to the partnership guide" do
      get lead_providers_landing_page_path

      expect(response.body).to include lead_providers_partnership_guide_path
    end

    it "should sign post visitors to the lead provider dashboard" do
      get lead_providers_landing_page_path

      expect(response.body).to include dashboard_path
    end
  end
end
