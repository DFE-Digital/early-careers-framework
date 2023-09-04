# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Schools::Dashboard", type: :request do
  let(:user) { create(:user, :induction_coordinator) }
  let(:school) { user.schools.first }

  before do
    travel_to Date.new(2022, 10, 1)
    sign_in user
  end

  describe "GET /schools" do
    let(:second_school) { create(:school) }
    before do
      user.induction_coordinator_profile.schools << second_school
    end

    it "renders the index schools template" do
      get "/schools"
      expect(response).to render_template("schools/dashboard/index")
      expect(response.body).to include(CGI.escapeHTML(school.name))
      expect(response.body).to include(CGI.escapeHTML(second_school.name))
    end
  end

  describe "GET /schools/:school_id" do
    let!(:cohort) { create :cohort, :current }

    it "should redirect to programme selection if programme not chosen" do
      get "/schools/#{school.slug}"

      expect(response).to redirect_to("/schools/#{school.slug}/cohorts/#{cohort.start_year}/setup")
    end

    it "should redirect to programme selection if programme not chosen" do
      # Also test the redirect in the base controller
      get "/schools/#{school.slug}/cohorts/#{cohort.start_year}/programme-choice"

      expect(response).to redirect_to("/schools/#{school.slug}/cohorts/#{cohort.start_year}/setup")
    end

    context "when the programme has been chosen" do
      before do
        create(:school_cohort, cohort:, school: user.induction_coordinator_profile.schools[0])
      end

      it "should render the dashboard" do
        get "/schools/#{school.slug}"

        expect(response).to render_template("schools/dashboard/show")
      end
    end
  end
end
