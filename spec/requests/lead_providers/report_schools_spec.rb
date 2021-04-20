# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Report schools spec", type: :request do
  describe "GET /lead_providers/report-schools/start" do
    it "should show the start page" do
      get start_lead_providers_report_schools_path

      expect(response).to render_template :start
    end
  end
end
