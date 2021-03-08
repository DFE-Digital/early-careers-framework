# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Admin::Administrators::Administrators", type: :request do
  let(:name) { Faker::Name.name }
  let(:email) { Faker::Internet.email }
  let(:new_user) { User.find_by(email: email) }

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

  describe "POST /admin/administrators/new/confirm" do
    it "renders the confirmation template" do
      given_i_have_previously_submitted_values(name, email)

      expect(response).to render_template("admin/administrators/administrators/confirm")
    end

    it "shows an error when a field is blank" do
      post "/admin/administrators/new/confirm", params: { user: {
        full_name: name,
        email: "",
      } }
      expect(response).to render_template("admin/administrators/administrators/new")
      expect(response.body).to include("Enter an email")
    end
  end

  describe "POST /admin/administrators" do
    it "creates a new user" do
      expect { create_new_user }.to change { User.count }.by 1
    end

    it "creates a new admin profile" do
      expect { create_new_user }.to change { AdminProfile.count }.by 1
    end

    it "confirms the new user" do
      given_a_user_is_created

      expect(new_user.confirmed?).to be true
    end

    it "makes the new user an admin" do
      given_a_user_is_created

      expect(new_user.admin?).to be true
    end

    it "renders a success message" do
      given_a_user_is_created

      expect(response).to render_template("admin/administrators/administrators/create")
    end
  end

private

  def given_i_have_previously_submitted_values(name, email)
    post "/admin/administrators/new/confirm", params: { user: {
      full_name: name,
      email: email,
    } }
  end

  def create_new_user
    post "/admin/administrators", params: { user: {
      full_name: name,
      email: email,
    } }
  end

  alias_method :given_a_user_is_created, :create_new_user
end
