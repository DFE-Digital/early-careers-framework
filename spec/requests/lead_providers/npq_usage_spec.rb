# frozen_string_literal: true

require "rails_helper"

RSpec.describe "NPQ usage guide", type: :request do
  describe "GET /lead-providers/guidance/npq-usage" do
    it "should show the NPQ usage guide" do
      get lead_providers_guidance_npq_usage_path

      expect(response.body).to include("Usage scenarios for NPQ Lead Providers")
    end

    it "should explain how to continue the NPQ application process" do
      get lead_providers_guidance_npq_usage_path

      expect(response.body).to include("Continuing the NPQ application process")
    end
  end
end
