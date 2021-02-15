# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Registrations::SchoolRegistered", type: :request do
  describe "GET /registrations/school-registered" do
    it "renders the show template" do
      get "/registrations/school-registered"
      expect(response).to render_template("registrations/school_registered/show")
    end
  end
end
