# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Schools::Partnerships", type: :request do
  let(:user) { create(:user, :induction_coordinator) }
  let(:school) { user.induction_coordinator_profile.schools.first }
  let(:cohort) { create(:cohort, start_year: 2021) }

  before do
    school
    sign_in user
  end

  describe "GET /schools/cohorts/:start_year/partnerships" do
    it "shows available delivery partners" do
      get "/schools/cohorts/#{cohort.start_year}/partnerships"

      expect(response).to render_template("schools/partnerships/index")
    end
  end
end
