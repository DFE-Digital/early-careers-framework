# frozen_string_literal: true

require "rails_helper"

RSpec.describe "InductionProgramme::Choices", type: :request do
  let(:school) { create(:school) }
  let(:induction_coordinator) { user.induction_coordinator_profile }
  let(:user) { create(:user, :induction_coordinator, confirmed_at: 2.hours.ago) }

  before do
    sign_in user
    induction_coordinator.schools << school
  end

  describe "GET /induction-programme/choices" do
    it "renders the show template" do
      get "/induction-programme/choices"
      expect(response.body).to include("Welcome to your account")
      expect(response).to render_template("induction_programme/choices/show")
    end
  end

  describe "POST /induction-programme/choices" do
    let(:school_cohort) { school.school_cohorts.last }

    it "saves the choice of induction programme" do
      post "/induction-programme/choices", params: { choice: "design_our_own" }

      expect(school_cohort.induction_programme_choice).to eq("design_our_own")
    end

    it "redirects to /registrations/learn-options if the choice is not_yet_known" do
      post "/induction-programme/choices", params: { choice: "not_yet_known" }
      expect(response).to redirect_to(:registrations_learn_options)
    end
  end
end
