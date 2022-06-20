# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Admin::Schools::Cohorts::ChangeTrainingMaterials", type: :request do
  let(:school_cohort) { create(:school_cohort) }
  let(:school) { school_cohort.school }
  let(:cohort) { school_cohort.cohort }

  before do
    sign_in create(:user, :admin)
  end

  describe "GET /admin/schools/:school_slug/cohorts/:id/change-training-materials" do
    it "renders the new template" do
      get "/admin/schools/#{school.slug}/cohorts/#{cohort.start_year}/change-training-materials"
      expect(response).to render_template "admin/schools/cohorts/change_training_materials/show"
    end
  end

  describe "POST /admin/schools/:school_slug/cohorts/:id/change-training-materials/confirm" do
    it "shows an error message if no reason is selected" do
      post "/admin/schools/#{school.slug}/cohorts/#{cohort.start_year}/change-training-materials/confirm", params: {
        core_induction_programme_choice_form: {
          core_induction_programme_id: "",
        },
      }

      expect(response).to render_template "admin/schools/cohorts/change_training_materials/show"
      expect(response.body).to include "Select the training materials you want to use"
    end

    it "shows a confirmation message" do
      post "/admin/schools/#{school.slug}/cohorts/#{cohort.start_year}/change-training-materials/confirm", params: {
        core_induction_programme_choice_form: {
          core_induction_programme_id: create(:core_induction_programme).id,
        },
      }

      expect(response).to render_template "admin/schools/cohorts/change_training_materials/confirm"
    end
  end

  describe "POST /admin/schools/:school_slug/cohorts/:id/change-training-materials" do
    let(:core_induction_programme) { create(:core_induction_programme) }

    it "calls Induction::ChangeCoreInductionProgramme with the correct arguments" do
      expect(Induction::ChangeCoreInductionProgramme).to receive(:call).with(
        school_cohort:,
        core_induction_programme:,
      )

      put "/admin/schools/#{school.slug}/cohorts/#{cohort.start_year}/change-training-materials", params: {
        core_induction_programme_choice_form: {
          core_induction_programme_id: core_induction_programme.id,
        },
      }
    end

    it "redirects to the cohorts page and shows a success message" do
      put "/admin/schools/#{school.slug}/cohorts/#{cohort.start_year}/change-training-materials", params: {
        core_induction_programme_choice_form: {
          core_induction_programme_id: core_induction_programme.id,
        },
      }

      expect(response).to redirect_to "/admin/schools/#{school.slug}/cohorts"
      follow_redirect!
      expect(response.body).to include "Training materials have been changed"
    end
  end
end
