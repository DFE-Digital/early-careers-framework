# frozen_string_literal: true

require "rails_helper"

RSpec.describe "NPQ usage guide", type: :request do
  describe "GET /lead-providers/guidance/npq-usage" do
    before do
      get lead_providers_guidance_npq_usage_path
    end

    it "should show the NPQ usage guide" do
      expect(response.body).to include("Usage scenarios for NPQ Lead Providers")
    end

    it "should explain how to continue the NPQ registration process" do
      expect(response.body).to include("Continuing the NPQ registration process")
    end

    it "should explain how to accept an NPQ application" do
      expect(response.body).to include("Accept an NPQ application")
    end

    it "should explain how to reject an NPQ application" do
      expect(response.body).to include("Reject an NPQ application")
    end

    it "should explain how to perform the NPQ participant started declaration process" do
      expect(response.body).to include("Declaring that an NPQ participant has started their course")
    end

    it "should explain how to perform the NPQ participant retained declaration process" do
      expect(response.body).to include("Declaring that an NPQ participant has reached a retained milestone")
    end

    it "should explain how to perform the NPQ participant completed declaration process" do
      expect(response.body).to include("Declaring that an NPQ participant has completed their course")
    end
  end
end
