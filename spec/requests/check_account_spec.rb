# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Check if you have an account page", type: :request do
  describe "GET /check-account" do
    it "renders the show template" do
      get "/check-account"
      expect(response).to render_template("check_account/show")
    end
  end
end
