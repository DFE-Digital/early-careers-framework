# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Registrations::SchoolNotEligible", type: :request do
  describe "GET /registrations/school-not-eligible" do
    it "renders the show template" do
      get "/registrations/school-not-eligible"
      expect(response).to render_template("registrations/school_not_eligible/show")
    end
  end
end
