# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Sandbox landing page", type: :request do
  describe "GET /sandbox" do
    it "should show the Sandbox landing page" do
      get sandbox_path

      expect(response).to render_template :show
      expect(response.body).to include("Use our sandbox to test Manage teacher CPD")
    end

    it "should explain how to get started as a Lead Provider" do
      get sandbox_path

      expect(response.body).to include "Get started as a lead provider"
    end

    it "should signpost visitors to the Lead Provider Guides" do
      get sandbox_path

      expect(response.body).to include "Continue as a training provider"
      expect(response.body).to include lead_providers_landing_page_path
    end

    it "should explain how to get started with the API" do
      get sandbox_path

      expect(response.body).to include "Get started with the API"
    end

    it "should signpost visitors to API documentation" do
      get sandbox_path

      expect(response.body).to include "Review our API documentation"
      expect(response.body).to include "/api-docs"
    end
  end
end
