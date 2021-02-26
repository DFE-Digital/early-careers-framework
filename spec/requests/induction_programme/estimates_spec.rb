# frozen_string_literal: true

require "rails_helper"

RSpec.describe "InductionProgramme::Estimates", type: :request do
  let(:school) { create(:school) }
  let(:cohort) { create(:cohort, start_year: 2021) }
  let(:induction_coordinator) { user.induction_coordinator_profile }
  let(:user) { create(:user, :induction_coordinator, confirmed_at: 2.hours.ago) }
  let!(:school_cohort) { SchoolCohort.create(cohort: cohort, school: school) }

  before do
    sign_in user
    induction_coordinator.schools << school
  end

  describe "GET /induction-programme/estimates" do
    it "renders the show template" do
      get "/induction-programme/estimates"
      expect(response).to render_template("induction_programme/estimates/show")
    end
  end

  describe "POST /induction-programme/estimates" do
    it "saves teacher and mentor estimates for the school cohort" do
      post "/induction-programme/estimates", params: { school_cohort_form: {
        estimated_teacher_count: 5, estimated_mentor_count: 2
      } }

      expect(school_cohort.reload.estimated_teacher_count).to be 5
      expect(school_cohort.reload.estimated_mentor_count).to be 2
      expect(response).to redirect_to :dashboard
    end

    it "renders errors when the form is invalid" do
      post "/induction-programme/estimates", params: { school_cohort_form: {
        estimated_teacher_count: nil, estimated_mentor_count: nil
      } }

      expect(response.body).to include("Enter your expected number of ECTs")
      expect(response).to render_template("induction_programme/estimates/show")
    end
  end
end
