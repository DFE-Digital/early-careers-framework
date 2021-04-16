# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Schools::ProgrammeChoice", type: :request do
  let(:user) { create(:user, :induction_coordinator) }
  let(:school) { user.induction_coordinator_profile.schools.first }
  let(:cohort) { create(:cohort, start_year: 2021) }
  let(:school_cohort) do
    create(:school_cohort, cohort: cohort, school: school, induction_programme_choice: "full_induction_programme")
  end

  before do
    school_cohort
    sign_in user
  end

  describe "GET /schools/cohorts/:start_year/programme-choice" do
    it "renders the programme-choice template" do
      get "/schools/cohorts/#{cohort.start_year}/programme-choice"

      expect(response).to render_template("schools/cohorts/programme_choice")
      expect(response.body).to include(CGI.escapeHTML("Your induction programme"))
    end
  end
end
