# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Health Check", type: :request do
  describe "GET /health_check" do
    it "returns success message for current health checks" do
      get "/healthcheck"

      expected = "success for following checks: ['database', 'migrations', 'email']"
      expect(response.body).to eq(expected)
    end
  end
end
