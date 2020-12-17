# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Users::InductionCoordinators::Registrations /check_email", type: :request do
  let(:school) { FactoryBot.create(:school) }
  let(:email) { Faker::Internet.email(domain: school.domains.first) }

  describe "GET /induction_coordinator/registration/check_email" do
    it "renders the correct template" do
      get "/induction_coordinator/registration/check_email"
      expect(response).to render_template(:start_registration)
    end
  end

  describe "POST /induction_coordinator/registration/check_email" do
    it "displays a warning when no schools are found" do
      # When
      post "/induction_coordinator/registration/check_email", params: { induction_coordinator_profile: {
        email: "something@random.com",
      } }

      # Then
      expect(response).to redirect_to(:induction_coordinator_registration_check_email)
      follow_redirect!
      expect(response).to render_template(:start_registration)
      expect(response.body).to include("No schools matched your email")
    end

    it "redirect to the school confirmation page when there is one matching school" do
      # When
      post "/induction_coordinator/registration/check_email", params: { induction_coordinator_profile: {
        email: email,
      } }

      # Then
      expect(response.redirect_url).to include(induction_coordinator_registration_school_confirmation_path)
      follow_redirect!
      expect(response.body).to include(school.name)
    end

    it "redirect to the school confirmation page when there are two matching schools" do
      # Given
      second_school = FactoryBot.create(:school)
      second_school.domains.push(school.domains.first)
      second_school.save!

      # When
      post "/induction_coordinator/registration/check_email", params: { induction_coordinator_profile: {
        email: email,
      } }

      # Then
      expect(response.redirect_url).to include(induction_coordinator_registration_school_confirmation_path)
      follow_redirect!
      expect(response.body).to include(school.name)
      expect(response.body).to include(second_school.name)
    end
  end
end
