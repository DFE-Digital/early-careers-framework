# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Registrations::SchoolNotConfirmed", type: :request do
  describe "GET /registrations/school-not-confirmed" do
    it "renders the show template" do
      get "/registrations/school-not-confirmed"
      expect(response).to render_template("registrations/school_not_confirmed/show")
    end
  end
end
