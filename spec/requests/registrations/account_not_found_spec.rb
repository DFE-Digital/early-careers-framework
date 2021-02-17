# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Registrations::AccountNotFound", type: :request do
  describe "GET /registrations/account-not-found" do
    it "renders the show template" do
      get "/registrations/account-not-found"
      expect(response).to render_template("registrations/account_not_found/show")
    end
  end
end
