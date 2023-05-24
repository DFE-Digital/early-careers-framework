# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Sandbox landing page", type: :request do
  describe "GET /sandbox" do
    it "should show the Sandbox landing page" do
      get sandbox_path

      expect(response).to render_template :show
      expect(response.body).to include("Use our sandbox environment")
    end

    it "should explain how to get started as an ECF Lead Provider" do
      get sandbox_path

      expect(response.body).to include "Impersonate ECF school induction tutors"
    end

    it "should signpost visitors to the Lead Provider Guidance" do
      get sandbox_path

      expect(response.body).to include "Login to sandbox as a school induction tutor"
      expect(response.body).to include lead_providers_landing_page_path
    end

    it "should explain how to get started with the API" do
      get sandbox_path

      expect(response.body).to include "Test API integrations with lead provider systems"
    end

    it "should signpost visitors to API documentation" do
      get sandbox_path

      expect(response.body).to include "View API guidance for lead providers"
      expect(response.body).to include "/api-reference"
    end
  end
end
