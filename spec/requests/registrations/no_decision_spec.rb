# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Registrations::AccountNotFound", type: :request do
  describe "GET /registrations/no-decision" do
    it "renders the show template" do
      get "/registrations/no-decision"
      expect(response).to render_template("registrations/no_decision/show")
    end
  end
end
