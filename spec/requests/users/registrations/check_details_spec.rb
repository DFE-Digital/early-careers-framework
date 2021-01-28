# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Users::Registrations /check-details", type: :request do
  let(:school) { FactoryBot.create(:school) }
  let(:email) { Faker::Internet.email(domain: school.domains.first) }

  describe "POST /users/check_email" do
    it "renders :start_registration when no schools are found" do
      # When
      post "/users/check-details", params: { induction_coordinator_profile: {
        email: "something@random.com", school_urn: "urn101"
      } }

      # Then
      expect(response).to render_template(:start_registration)
    end

    it "renders :school_not_registered when school has not been claimed" do
      # When
      post "/users/check-details", params: { induction_coordinator_profile: {
        email: email, school_urn: school.urn
      } }

      # Then
      expect(school.reload.not_registered?).to be true
      expect(response).to render_template(:school_not_registered)
      expect(response.body).to include(CGI.escapeHTML(school.name))
    end

    context "when the user is already registered" do
      before { create(:user, email: email) }
      it "renders :user_already_registered" do
        # When
        post "/users/check-details", params: { induction_coordinator_profile: {
          email: email, school_urn: school.urn
        } }

        # Then
        expect(response.body).to include(user_session_path)
        expect(response).to render_template(:user_already_registered)
      end
    end

    context "when the school is ineligible for the core induction programme" do
      before { school.update(eligible: false) }
      it "renders :school_not_eligible" do
        # When
        post "/users/check-details", params: { induction_coordinator_profile: {
          email: email, school_urn: school.urn
        } }

        # Then
        expect(school.eligible?).to be false
        expect(response).to render_template(:school_not_eligible)
      end
    end

    context "when the school is already fully registered" do
      let(:user) { create(:user, confirmed_at: 2.days.ago) }
      let!(:coordinator) { create(:induction_coordinator_profile, user: user, schools: [school]) }

      it "renders :school_fully_registered" do
        # When
        post "/users/check-details", params: { induction_coordinator_profile: {
          email: email, school_urn: school.urn
        } }

        # Then
        expect(response).to render_template(:school_fully_registered)
      end
    end

    context "when the school is partially registered" do
      let(:user) { create(:user, confirmed_at: nil) }
      let!(:coordinator) { create(:induction_coordinator_profile, user: user, schools: [school]) }

      it "renders :school_partially_registered" do
        # When
        post "/users/check-details", params: { induction_coordinator_profile: {
          email: email, school_urn: school.urn
        } }

        # Then
        expect(response).to render_template(:school_partially_registered)
      end
    end
  end
end
