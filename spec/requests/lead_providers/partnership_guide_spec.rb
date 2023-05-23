# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Lead Provider partnership guide", type: :request do
  describe "GET /lead-providers/partnership-guide" do
    it "should show the Lead Provider partnership guide" do
      get lead_providers_partnership_guide_path

      expect(response.body).not_to include("##")
    end

    it "should explain how to confirm the schools you have recruited" do
      get lead_providers_partnership_guide_path

      expect(response.body).to include("How to confirm partnerships with schools using CSVs")
    end

    it "should explain how to check errors and update their CSV" do
      get lead_providers_partnership_guide_path

      expect(response.body).to include("How to check CSV upload errors")
    end

    it "should explain what to do when a school reports they have been confirmed incorrectly" do
      get lead_providers_partnership_guide_path

      expect(response.body).to include("How school induction tutors report incorrect partnerships")
    end

    it "should explain how to check the schools they have recruited" do
      get lead_providers_partnership_guide_path

      expect(response.body).to include("View ECT, mentor and induction tutor details")
    end
  end
end
