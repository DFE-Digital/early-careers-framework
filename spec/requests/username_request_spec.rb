# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Usernames", type: :request do
  let(:user) { create(:user, account_created: false) }

  before do
    sign_in user
  end

  describe "GET /username/new" do
    it "renders new template" do
      get "/username/new"
      expect(response).to render_template(:new)
    end
  end

  describe "POST /username" do
    it "redirects to dashboard" do
      post "/username", params: { user: { username: "Test" } }
      expect(response).to redirect_to(dashboard_path)
    end

    it "sets username and account_created" do
      post "/username", params: { user: { username: "Test" } }
      expect(user.reload.account_created).to be_truthy
      expect(user.username).to eq("Test")
    end
  end

  describe "GET /username/edit" do
    it "renders edit template" do
      get "/username/edit"
      expect(response).to render_template(:edit)
    end
  end

  describe "PUT /username" do
    it "redirects successfully" do
      put "/username", params: { user: { username: "Test" } }
      expect(response).to redirect_to(dashboard_path)
    end

    it "sets username and account_created" do
      post "/username", params: { user: { username: "Test" } }
      expect(user.username).to eq("Test")
    end
  end
end
