# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Registrations::Starts", type: :request do
  describe "GET /registrations/start" do
    it "renders the index template" do
      get "/registrations"
      expect(response).to render_template("registrations/start/index")
    end
  end
end
