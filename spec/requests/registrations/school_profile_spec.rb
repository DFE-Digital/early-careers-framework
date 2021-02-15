# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Registrations::SchoolProfile", type: :request do
  describe "GET /registrations/school-profile" do
    it "renders the show template" do
      get "/registrations/school-profile"
      expect(response).to render_template("registrations/school_profile/show")
    end
  end
end
