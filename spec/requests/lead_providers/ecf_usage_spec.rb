# frozen_string_literal: true

require "rails_helper"

RSpec.describe "ECF usage guide", type: :request do
  describe "GET /lead-providers/guidance/ecf-usage" do
    it "should show the ECF usage guide" do
      get lead_providers_guidance_ecf_usage_path

      expect(response.body).to include("Usage scenarios for ECF Lead Providers")
    end

    it "should explain how to continue the ECF registration process" do
      get lead_providers_guidance_ecf_usage_path

      expect(response.body).to include("Continuing the ECF registration process")
    end

    it "should explain how to declare that an ECF participant has started their induction" do
      get lead_providers_guidance_ecf_usage_path

      expect(response.body).to include("Declaring that an ECF participant has started their induction")
    end
  end
end
