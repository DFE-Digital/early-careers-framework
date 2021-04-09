# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Usernames", type: :request do
  let(:user) { create(:user) }

  before do
    sign_in user
  end

  describe "GET /username/edit" do
    it "returns http success" do
      get "/username/edit"
      expect(response).to have_http_status(:success)
    end
  end

  describe "PUT /username" do
    it "redirects successfully" do
      put "/username", params: { user: { username: "Test" } }
      expect(response).to redirect_to(dashboard_path)
    end
  end
end
