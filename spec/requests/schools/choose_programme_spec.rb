# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Schools::ChooseProgramme", type: :request do
  let(:user) { create(:user, :induction_coordinator) }
  let(:school) { user.induction_coordinator_profile.schools.first }
  let(:cohort) { create(:cohort, start_year: 2021) }

  before do
    cohort
    sign_in user
  end

  describe "GET /schools/choose-programme" do
    it "renders the choose programme template" do
      get "/schools/choose-programme"

      expect(response).to render_template("schools/choose_programme/show")
    end

    context "when the school has chosen provision" do
      before do
        SchoolCohort.create!(school: school, cohort: cohort, induction_programme_choice: "full_induction_programme")
      end

      it "redirects to the dashboard" do
        get "/schools/choose-programme"

        expect(response).to redirect_to("/schools")
      end
    end
  end

  describe "POST /schools/choose-programme" do
    it "should show an error if nothing is selected" do
      post "/schools/choose-programme", params: { induction_choice_form: { programme_choice: "" } }

      expect(response).to render_template("schools/choose_programme/show")
      expect(response.body).to include("Select one")
    end

    it "should store the induction choice" do
      induction_programme_choice = "full_induction_programme"
      expect {
        post "/schools/choose-programme", params: { induction_choice_form: { programme_choice: induction_programme_choice } }
      }.to change { SchoolCohort.count }.by(1)

      created_school_cohort = school.school_cohorts.find_by(cohort: cohort)
      expect(created_school_cohort.induction_programme_choice).to eq induction_programme_choice
    end
  end
end
