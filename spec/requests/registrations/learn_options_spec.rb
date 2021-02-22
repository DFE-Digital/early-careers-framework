# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Registrations::LearnOptions", type: :request do
  describe "GET /registrations/learn-options" do
    it "renders the show template" do
      get "/registrations/learn-options"
      expect(response).to render_template("registrations/learn_options/show")
    end
  end
end
