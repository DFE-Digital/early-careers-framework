# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Admin::Schools::Cohorts", type: :request do
  let(:admin_user) { create(:user, :admin) }
  let(:school) { create(:school) }
  let(:cip) { create(:core_induction_programme, name: "CIP Programme") }
  let!(:school_cohorts) do
    [
      create(:school_cohort, school: school, core_induction_programme: cip),
      create(:school_cohort, school: school),
      create(:school_cohort, school: school, induction_programme_choice: "full_induction_programme"),
      create(:school_cohort, school: school, induction_programme_choice: "no_early_career_teachers"),
      create(:school_cohort, school: school, induction_programme_choice: "design_our_own"),
    ]
  end
  let!(:cohort_without_programme_chosen) { create(:cohort) }

  before do
    sign_in admin_user
  end

  describe "GET /admin/schools/:school_id/cohorts" do
    it "renders the index template" do
      get "/admin/schools/#{school.id}/cohorts"
      expect(response).to render_template("admin/schools/cohorts/index")
      expect(assigns(:school_cohorts)).to match_array school.school_cohorts
      Cohort.all.each do |cohort|
        expect(response.body).to include cohort.start_year.to_s
      end
    end

    it "does not display the 2020 cohort because it is weird" do
      create(:cohort, start_year: 2020)
      get "/admin/schools/#{school.id}/cohorts"
      expect(response.body).not_to include "2020 Cohort"
    end
  end
end
