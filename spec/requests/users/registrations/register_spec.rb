# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Users::Registrations /register", type: :request do
  let(:school) { FactoryBot.create(:school) }
  let(:full_name) { Faker::Name.name }
  let(:email) { Faker::Internet.email(domain: school.domains.first) }

  describe "POST /users/register" do
    it "renders :verification_email_sent" do
      # When
      post "/users/register", params: { user: {
        full_name: full_name,
        email: email,
        school_id: school.id,
      } }

      # Then
      expect(response).to render_template(:verification_email_sent)
    end

    it "creates a user with the correct details" do
      # When
      post "/users/register", params: { user: {
        full_name: full_name,
        email: email,
        school_id: school.id,
      } }

      # Then
      created_user = User.find_by_email(email)

      expect(created_user).not_to be_nil
      expect(created_user.full_name).to eq(full_name)
    end

    it "creates an induction coordinator profile for the user" do
      # When
      post "/users/register", params: { user: {
        full_name: full_name,
        email: email,
        school_id: school.id,
      } }

      # Then
      created_user = User.find_by_email(email)

      expect(created_user.induction_coordinator_profile).not_to be_nil
    end

    it "makes the user the induction coordinator for the school" do
      # When
      post "/users/register", params: { user: {
        full_name: full_name,
        email: email,
        school_id: school.id,
      } }

      # Then
      created_user = User.find_by_email(email)

      expect(created_user.induction_coordinator_profile.schools).to include(school)
    end

    it "returns bad request when the email does not match the school" do
      expect {
        post "/users/register", params: { user: {
          full_name: full_name,
          email: "email@differentdomain.com",
          school_id: school.id,
        } }
      }.to raise_error(ActionController::BadRequest)
    end

    it "returns bad request when the email is missing" do
      expect {
        post "/users/register", params: { user: {
          full_name: full_name,
          school_id: school.id,
        } }
      }.to raise_error(ActionController::BadRequest)
    end

    it "returns bad request when the school_id is missing" do
      expect {
        post "/users/register", params: { user: {
          full_name: full_name,
          email: email,
        } }
      }.to raise_error(ActionController::BadRequest)
    end

    context "when school has old unconfirmed registrations" do
      let(:user) { create(:user, confirmed_at: nil) }
      let!(:coordinator) { create(:induction_coordinator_profile, user: user, schools: [school]) }
      let(:created_user) { User.find_by_email(email) }

      before { user.update(confirmation_sent_at: 2.days.ago) }

      it "registers new induction coordinator and removes the old coordinator profiles" do
        post "/users/register", params: { user: {
          full_name: full_name,
          email: email,
          school_id: school.id,
        } }

        expect(school.reload.induction_coordinator_profiles).to include created_user.induction_coordinator_profile
        expect(school.induction_coordinator_profiles).not_to include user.reload.induction_coordinator_profile
      end
    end
  end
end
