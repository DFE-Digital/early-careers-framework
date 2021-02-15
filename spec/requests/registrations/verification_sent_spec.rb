# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Registrations::VerificationSent", type: :request do 
  describe "GET /registrations/verification-sent" do
    it "renders the show template" do
      get "/registrations/verification-sent"
      expect(response).to render_template("registrations/verification_sent/show")
    end
  end
end
