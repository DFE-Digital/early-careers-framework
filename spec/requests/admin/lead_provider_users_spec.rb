# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Admin::LeadProviderUsers", type: :request do
  let(:lead_provider) { FactoryBot.create(:lead_provider) }
  let(:user) { FactoryBot.create(:user, lead_provider: lead_provider) }
  let(:first_name) { Faker::Name.first_name }
  let(:last_name) { Faker::Name.last_name }
  let(:email) { Faker::Internet.email }

  before do
    admin_user = create(:user, :admin)
    sign_in admin_user
  end

  describe "GET /admin/lead_providers/:id/users" do
    it "renders the correct template" do
      # When
      get "/admin/lead_providers/#{lead_provider.id}/users"

      # Then
      expect(response).to render_template(:index)
    end
  end

  describe "POST /admin/lead_providers/:id/users" do
    it "redirects to the list of users on success" do
      # When
      post "/admin/lead_providers/#{lead_provider.id}/users", params: { user: {
        first_name: "First",
        last_name: "Last",
        email: "first.last@email.com",
      } }

      # Then
      expect(response).to redirect_to("/admin/lead_providers/#{lead_provider.id}/users")
    end

    it "creates a new user" do
      expect {
        post "/admin/lead_providers/#{lead_provider.id}/users", params: { user: {
          first_name: first_name,
          last_name: last_name,
          email: email,
        } }
      }.to change { User.count }.by(1)
    end

    it "creates a user with the correct details" do
      # When
      post "/admin/lead_providers/#{lead_provider.id}/users", params: { user: {
        first_name: first_name,
        last_name: last_name,
        email: email,
      } }

      # Then
      new_user = User.find_by_email(email)
      expect(new_user).not_to be_nil
      expect(new_user.first_name).to eq(first_name)
      expect(new_user.last_name).to eq(last_name)
    end

    it "does not create a user when the first name is empty" do
      expect {
        post "/admin/lead_providers/#{lead_provider.id}/users", params: { user: {
          first_name: "",
          last_name: last_name,
          email: email,
        } }
      }.not_to(change { User.count })
    end

    it "does not create a user when the last name is empty" do
      expect {
        post "/admin/lead_providers/#{lead_provider.id}/users", params: { user: {
          first_name: first_name,
          last_name: "",
          email: email,
        } }
      }.not_to(change { User.count })
    end

    it "does not create a user when the email is empty" do
      expect {
        post "/admin/lead_providers/#{lead_provider.id}/users", params: { user: {
          first_name: first_name,
          last_name: last_name,
          email: "",
        } }
      }.not_to(change { User.count })
    end

    it "shows an error message when the first name is empty" do
      # When
      post "/admin/lead_providers/#{lead_provider.id}/users", params: { user: {
        first_name: "",
        last_name: last_name,
        email: email,
      } }

      # Then
      expect(response.body).to include("Enter a first name")
    end
  end

  describe "GET /admin/lead_providers/:lead_provider/users/new" do
    it "renders the correct template" do
      # When
      get "/admin/lead_providers/#{lead_provider.id}/users/new"

      # Then
      expect(response).to render_template(:new)
    end
  end

  describe "GET /admin/lead_providers/:lead_provider/users/:id/edit" do
    it "renders the correct template" do
      # When
      get "/admin/lead_providers/#{lead_provider.id}/users/#{user.id}/edit"

      # Then
      expect(response).to render_template(:edit)
    end

    it "displays the current name of the user" do
      # When
      get "/admin/lead_providers/#{lead_provider.id}/users/#{user.id}/edit"

      # Then
      expect(response.body).to include(CGI.escapeHTML(user.first_name))
    end
  end

  describe "PUT /admin/lead_providers/:id/users/:id" do
    it "redirects to the list of lead providers" do
      # When
      put "/admin/lead_providers/#{lead_provider.id}/users/#{user.id}", params: { user: {
        first_name: first_name,
        last_name: user.last_name,
        email: user.email,
      } }

      # Then
      expect(response).to redirect_to("/admin/lead_providers/#{lead_provider.id}/users")
    end

    it "updates the name of an existing user" do
      # When
      put "/admin/lead_providers/#{lead_provider.id}/users/#{user.id}", params: { user: {
        first_name: first_name,
        last_name: user.last_name,
        email: user.email,
      } }

      # Then
      expect(User.find(user.id).first_name).to eq(first_name)
    end

    it "does not update the name of the user when the new first name is blank" do
      # Given
      previous_name = user.first_name

      # When
      put "/admin/lead_providers/#{lead_provider.id}/users/#{user.id}", params: { user: {
        first_name: "",
        last_name: user.last_name,
        email: user.email,
      } }

      # Then
      expect(User.find(user.id).first_name).to eq(previous_name)
    end

    it "displays an error message when the name is blank" do
      # When
      put "/admin/lead_providers/#{lead_provider.id}/users/#{user.id}", params: { user: {
        first_name: "",
        last_name: user.last_name,
        email: user.email,
      } }

      # Then
      expect(response.body).to include("Enter a first name")
    end
  end
end
