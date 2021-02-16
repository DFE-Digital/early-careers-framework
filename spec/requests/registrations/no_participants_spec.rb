# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Registrations::NoParticipants", type: :request do
  describe "GET /registrations/no-participants" do
    it "renders the show template" do
      get "/registrations/no-participants"
      expect(response).to render_template("registrations/no_participants/show")
    end
  end
end
