# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Users::InductionCoordinators::Registrations /register", type: :request do
  let(:school) { FactoryBot.create(:school) }
  let(:first_name) { Faker::Name.first_name }
  let(:last_name) { Faker::Name.last_name }
  let(:email) { Faker::Internet.email(domain: school.domains.first) }

  describe "GET /induction_coordinator/registration/register" do
    it "renders the correct template" do
      get "/induction_coordinator/registration/register", params: { school_id: school.id }
      expect(response).to render_template(:new)
    end
  end

  describe "POST /induction_coordinator/registration/register" do
    it "redirects to dashboard on successful user creation" do
      # When
      post "/induction_coordinator/registration/register", params: { user: {
        first_name: first_name,
        last_name: last_name,
        email: email,
        school_id: school.id,
      } }

      # Then
      expect(response).to redirect_to(root_path)
    end

    it "creates a user with the correct details" do
      # When
      post "/induction_coordinator/registration/register", params: { user: {
        first_name: first_name,
        last_name: last_name,
        email: email,
        school_id: school.id,
      } }

      # Then
      created_user = User.find_by_email(email)

      expect(created_user).not_to be_nil
      expect(created_user.first_name).to eq(first_name)
      expect(created_user.last_name).to eq(last_name)
    end

    it "creates an induction coordinator profile for the user" do
      # When
      post "/induction_coordinator/registration/register", params: { user: {
        first_name: first_name,
        last_name: last_name,
        email: email,
        school_id: school.id,
      } }

      # Then
      created_user = User.find_by_email(email)

      expect(created_user.induction_coordinator_profile).not_to be_nil
    end

    it "makes the user the induction coordinator for the school" do
      # When
      post "/induction_coordinator/registration/register", params: { user: {
        first_name: first_name,
        last_name: last_name,
        email: email,
        school_id: school.id,
      } }

      # Then
      created_user = User.find_by_email(email)

      expect(created_user.induction_coordinator_profile.schools).to include(school)
    end
  end
end
