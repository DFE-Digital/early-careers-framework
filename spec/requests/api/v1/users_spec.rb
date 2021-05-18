# frozen_string_literal: true

require "rails_helper"

RSpec.describe "API Users", type: :request do
  describe "#index" do
    let(:parsed_response) { JSON.parse(response.body) }

    before :each do
      3.times { create(:user) }
    end

    it "returns correct jsonapi content type header" do
      get "/api/v1/users"
      expect(response.headers["Content-Type"]).to eql("application/vnd.api+json")
    end

    it "returns all users" do
      get "/api/v1/users"
      expect(parsed_response["data"].size).to eql(3)
    end

    it "returns correct type" do
      get "/api/v1/users"
      expect(parsed_response["data"][0]).to have_type("user")
    end

    it "returns IDs" do
      get "/api/v1/users"
      expect(parsed_response["data"][0]["id"]).to be_in(User.pluck(:id))
    end

    it "returns only email and full name in attributes" do
      get "/api/v1/users"
      expect(parsed_response["data"][0]).to have_jsonapi_attributes(:email, :full_name).exactly
    end
  end
end
