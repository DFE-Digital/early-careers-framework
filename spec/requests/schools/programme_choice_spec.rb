# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Schools::ProgrammeChoice", type: :request, travel_to: Date.new(2021, 11, 1) do
  let(:user) { create(:user, :induction_coordinator) }
  let(:school) { user.induction_coordinator_profile.schools.first }
  let(:cohort) { create(:cohort, start_year: 2021) }
  let(:school_cohort) do
    create(:school_cohort, cohort:, school:, induction_programme_choice: "full_induction_programme")
  end

  before do
    school_cohort
    sign_in user
  end

  describe "GET /schools/:school_id/cohorts/:start_year" do
    it "renders the show template" do
      get "/schools/#{school.slug}/cohorts/#{cohort.start_year}"
      expect(response).to render_template("schools/cohorts/programme_choice")
    end

    context "when the school has no early career teachers for the cohort" do
      before do
        school_cohort.no_early_career_teachers!
      end

      it "redirects back to the school dashboard" do
        get "/schools/#{school.slug}/cohorts/#{cohort.start_year}"
        expect(response).to redirect_to "/schools/#{school.slug}"
      end
    end

    context "when the school will design their own programme for the cohort" do
      before do
        school_cohort.design_our_own!
      end

      it "redirects back to the school dashboard" do
        get "/schools/#{school.slug}/cohorts/#{cohort.start_year}"
        expect(response).to redirect_to "/schools/#{school.slug}"
      end
    end
  end

  describe "GET /schools/:school_id/cohorts/:start_year/programme-choice" do
    it "renders the programme-choice template" do
      get "/schools/#{school.slug}/cohorts/#{cohort.start_year}/programme-choice"

      expect(response).to render_template("schools/cohorts/programme_choice")
      expect(response.body).to include(CGI.escapeHTML("Your induction programme"))
    end
  end
end
