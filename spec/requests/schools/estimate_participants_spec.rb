# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Schools::EstimateParticipants", type: :request do
  let(:user) { create(:user, :induction_coordinator) }
  let(:school_cohort) { create(:school_cohort) }

  before do
    sign_in user
  end

  describe "GET /schools/estimate-participants/:id/edit" do
    it "should render the edit form and assign instance vars" do
      get edit_schools_estimate_participant_path(school_cohort)

      expect(response).to render_template(:edit)
      expect(assigns(:school_cohort)).to eq(school_cohort)
      expect(assigns(:school_cohort_form)).to be_an_instance_of SchoolCohortForm
    end
  end

  describe "PATCH /schools/estimate-participants/:id" do
    it "updates the school_cohort and redirects to task list" do
      form_params = {
        school_cohort_form: {
          estimated_mentor_count: 20,
          estimated_teacher_count: 30,
        },
      }
      patch schools_estimate_participant_path(school_cohort), params: form_params
      school_cohort.reload
      expect(school_cohort.estimated_mentor_count).to eq 20
      expect(school_cohort.estimated_teacher_count).to eq 30
      # do we need this here, should really be part of cypress tests ?
      expect(response).to redirect_to(schools_cohort_path(school_cohort.cohort.start_year))
    end
  end
end
