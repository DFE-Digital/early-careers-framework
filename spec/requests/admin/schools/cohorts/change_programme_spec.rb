# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Admin::Schools::Cohorts::ChangeProgramme", type: :request do
  let(:school_cohort) { create(:school_cohort) }
  let(:school) { school_cohort.school }
  let(:cohort) { school_cohort.cohort }

  before do
    sign_in create(:user, :admin)
  end

  describe "GET /admin/schools/:school_slug/cohorts/:id/change-programme" do
    it "renders the show template" do
      get "/admin/schools/#{school.slug}/cohorts/#{cohort.start_year}/change-programme"
      expect(response).to render_template "admin/schools/cohorts/change_programme/show"
    end
  end

  describe "POST /admin/schools/:school_slug/cohorts/:id/change-programme/confirm" do
    it "shows an error message if no programme is selected" do
      post "/admin/schools/#{school.slug}/cohorts/#{cohort.start_year}/change-programme/confirm", params: {
        induction_choice_form: { programme_choice: "" },
      }
      expect(response).to render_template "admin/schools/cohorts/change_programme/show"
      expect(response.body).to include "Select how you want to run your training"
    end

    it "shows a confirmation message" do
      post "/admin/schools/#{school.slug}/cohorts/#{cohort.start_year}/change-programme/confirm", params: {
        induction_choice_form: { programme_choice: "full_induction_programme" },
      }
      expect(response).to render_template "admin/schools/cohorts/change_programme/confirm"
    end
  end

  describe "PUT /admin/schools/:school_slug/cohorts/:id/change-programme" do
    it "call Induction::ChangeCohortInductionProgramme with the correct argument" do
      expect(Induction::ChangeCohortInductionProgramme).to receive(:call).with(
        school_cohort:,
        programme_choice: :full_induction_programme,
      )

      put "/admin/schools/#{school.slug}/cohorts/#{cohort.start_year}/change-programme", params: {
        induction_choice_form: { programme_choice: "full_induction_programme" },
      }
    end

    it "redirects to the cohorts page and shows a success message" do
      put "/admin/schools/#{school.slug}/cohorts/#{cohort.start_year}/change-programme", params: {
        induction_choice_form: { programme_choice: "full_induction_programme" },
      }
      expect(response).to redirect_to "/admin/schools/#{school.slug}/cohorts"
      follow_redirect!
      expect(response.body).to include "Induction programme has been changed"
    end
  end

  context "when given school cohort does not yet exist" do
    let(:school) { create :school }
    let(:cohort) { create :cohort }

    it "renders show page" do
      get "/admin/schools/#{school.slug}/cohorts/#{cohort.start_year}/change-programme"
      expect(assigns(:school_cohort)).not_to be_persisted
    end
  end
end
