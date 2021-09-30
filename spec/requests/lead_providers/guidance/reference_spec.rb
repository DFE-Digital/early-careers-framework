# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Lead Providers guidance reference", type: :request do
  describe "GET /lead-providers/guidance/reference" do
    it "should return a 200 response" do
      get "/lead-providers/guidance/reference"

      expect(response.status).to eq(200)
    end
  end
end
