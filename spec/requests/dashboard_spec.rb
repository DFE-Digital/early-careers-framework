# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Dashboard", type: :request do
  let(:lead_provider) { create(:user, :lead_provider) }

  before do
    sign_in lead_provider
    Cohort.create!(start_year: "2021")
  end

  describe "GET /dashboard" do
    it "renders the show template" do
      get "/dashboard"
      expect(response).to render_template("dashboard/show")
    end
  end
end
