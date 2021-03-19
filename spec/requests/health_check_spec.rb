# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Health Check", type: :request do
  describe "GET /health_check" do
    it "returns success message for current health checks" do
      get "/healthcheck"

      expected = "success for following checks: ['database', 'migrations']"
      expect(response.body).to eq(expected)
    end

    context "failed database check" do
      before(:each) do
        expect(ActiveRecord::Migration).to receive(:check_pending!).and_raise(ActiveRecord::PendingMigrationError, "Migration is pending")
      end

      it "returns error if database is not migrated correctly" do
        get "/healthcheck"

        expected = "failure"
        expect(response.body).to eq(expected)
      end
    end
  end
end
