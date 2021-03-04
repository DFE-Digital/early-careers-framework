# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Admin::Administrators::Administrators", type: :request do
  let(:name) { Faker::Name.name }
  let(:email) { Faker::Internet.email }

  before do
    user = create(:user, :admin)
    sign_in user
  end

  describe "GET /admin/administrators" do
    it "renders the index template" do
      get "/admin/administrators"
      expect(response).to render_template("admin/administrators/administrators/index")
    end
  end

  describe "GET /admin/administrators/new" do
    it "renders the new template" do
      get "/admin/administrators/new"
      expect(response).to render_template("admin/administrators/administrators/new")
    end
  end

  describe "POST /admin/administrators" do
    it "redirects to the confirmation page" do
      post "/admin/administrators", params: { user: {
        full_name: name,
        email: email,
      } }

      expect(response).to redirect_to("/admin/administrators/new/confirm?email=#{CGI.escape(email)}&full_name=#{CGI.escape(name)}")
    end

    it "shows an error when a field is blank" do
      post "/admin/administrators", params: { user: {
        full_name: name,
        email: "",
      } }
      expect(response).to render_template("admin/administrators/administrators/new")
      expect(response.body).to include("Enter an email")
    end
  end
end
