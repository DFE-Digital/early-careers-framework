# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Users::Registrations", type: :request do
  describe "GET /users/information" do
    it "renders the correct template" do
      get "/users/information"
      expect(response).to render_template(:info)
    end
  end

  describe "GET /users/new" do
    it "renders the correct template" do
      get "/users/new"
      expect(response).to render_template(:new)
    end
  end
end
