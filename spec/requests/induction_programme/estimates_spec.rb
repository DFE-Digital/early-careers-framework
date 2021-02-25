# frozen_string_literal: true

require "rails_helper"

RSpec.describe "InductionProgramme::Estimates", type: :request do
  describe "GET /induction-programme/estimates" do
    it "returns http success" do
      get "/induction-programme/estimates"
      expect(response).to have_http_status(:success)
    end
  end
end
