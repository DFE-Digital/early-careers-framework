# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Dashboard", type: :request do
  let(:cohort) { create(:cohort ,:current) }
  let(:lead_provider_user) { lead_provider_profile.user }
  let(:lead_provider_profile) { create(:lead_provider_profile) }

  before do
    cohort
    sign_in lead_provider_user
  end

  describe "GET /dashboard" do
    it "renders the show template" do
      get "/dashboard"
      expect(response).to render_template("dashboard/show")
      expect(response.body).to include start_lead_providers_report_schools_path
    end
  end
end
