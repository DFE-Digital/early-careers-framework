# frozen_string_literal: true

require "rails_helper"

RSpec.describe "API Users", type: :request do
  describe "index" do
    let(:parsed_response) { JSON.parse(response.body) }

    before :each do
      10.times { create(:user) }
    end

    it "returns all users in 'users' field" do
      get "/api/v1/users"
      expect(parsed_response["users"].count).to eq 10
    end

    it "returns only id, email and full name" do
      get "/api/v1/users"
      expect(parsed_response["users"][0].keys).to contain_exactly("id", "full_name", "email")
    end
  end
end
