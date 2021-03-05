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

    it "prefills fields when passed the continue parameter" do
      given_i_have_previously_submitted_values(name, email)

      get "/admin/administrators/new?continue=true"

      expect(response.body).to include(CGI.escapeHTML(email))
      expect(response.body).to include(CGI.escapeHTML(name))
    end

    it "clears fields when not passed the continue parameter" do
      given_i_have_previously_submitted_values(name, email)

      get "/admin/administrators/new"

      expect(response.body).not_to include(CGI.escapeHTML(email))
      expect(response.body).not_to include(CGI.escapeHTML(name))
    end
  end

  describe "POST /admin/administrators" do
    it "renders the confirmation template" do
      given_i_have_previously_submitted_values(name, email)

      expect(response).to render_template("admin/administrators/administrators/create")
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

private

  def given_i_have_previously_submitted_values(name, email)
    post "/admin/administrators", params: { user: {
      full_name: name,
      email: email,
    } }
  end
end
