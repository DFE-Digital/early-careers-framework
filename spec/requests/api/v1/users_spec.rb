# frozen_string_literal: true

require "rails_helper"

RSpec.describe "API Users", type: :request do
  describe "#index" do
    let(:token) { EngageAndLearnApiToken.create_with_random_token! }
    let(:bearer_token) { "Bearer #{token}" }

    let(:parsed_response) { JSON.parse(response.body) }

    before :each do
      3.times { create(:user) }
    end

    context "when authorized" do
      before do
        default_headers[:Authorization] = bearer_token
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
        expect(parsed_response["data"][0]).to have_jsonapi_attributes(:email, :full_name, :user_type, :core_induction_programme).exactly
      end

      it "returns the right number of users per page" do
        get "/api/v1/users", params: { page: { per_page: 2, page: 1 } }
        expect(parsed_response["data"].size).to eql(2)
      end

      it "returns different users for each page" do
        User.delete_all
        3.times { create(:user) }

        get "/api/v1/users", params: { page: { per_page: 2, page: 1 } }
        expect(parsed_response["data"].size).to eql(2)

        get "/api/v1/users", params: { page: { per_page: 2, page: 2 } }
        expect(JSON.parse(response.body)["data"].size).to eql(1)
      end
    end

    context "when unauthorized" do
      it "returns 401 for invalid bearer token" do
        default_headers[:Authorization] = "Bearer ugLPicDrpGZdD_w7hhCL"
        get "/api/v1/users"
        expect(response.status).to eq 401
      end
    end
  end
end
