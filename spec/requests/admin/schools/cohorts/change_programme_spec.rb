# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Admin::Schools::Cohorts::ChangeProgramme", type: :request do
  let(:school_cohort) { create(:school_cohort) }
  let(:school) { school_cohort.school }
  let(:cohort) { school_cohort.cohort }

  before do
    user = create(:user, :admin)
    sign_in user
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
      expect(response.body).to include "Select how you want to run your induction"
    end

    it "shows a confirmation message" do
      post "/admin/schools/#{school.slug}/cohorts/#{cohort.start_year}/change-programme/confirm", params: {
        induction_choice_form: { programme_choice: "full_induction_programme" },
      }
      expect(response).to render_template "admin/schools/cohorts/change_programme/confirm"
    end
  end

  describe "PUT /admin/schools/:school_slug/cohorts/:id/change-programme" do
    it "call ChangeInductionService with the correct argument" do
      expect_any_instance_of(Admin::ChangeInductionService).to receive(:change_induction_provision)
                                                                 .with(:full_induction_programme)

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
end
