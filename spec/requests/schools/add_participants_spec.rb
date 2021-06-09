# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Schools::AddParticipants", type: :request do
  let(:user) { create(:user, :induction_coordinator) }
  let(:school) { user.induction_coordinator_profile.schools.first }
  let(:cohort) { create(:cohort, start_year: 2021) }
  let!(:school_cohort) do
    create(:school_cohort, cohort: cohort, school: school, induction_programme_choice: "full_induction_programme")
  end

  before do
    FeatureFlag.deactivate(:induction_tutor_manage_participants)
    sign_in user
  end

  describe "GET /schools/cohorts/:start_year/add-participants" do
    it "renders the add-participants template" do
      get "/schools/cohorts/#{cohort.start_year}/add-participants"

      expect(response).to render_template("schools/cohorts/add_participants")
      expect(response.body).to include(CGI.escapeHTML("Add early career teachers and mentors"))
    end
  end
end
