# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Schools::Dashboard", type: :request do
  let(:user) { create(:user, :induction_coordinator) }

  before do
    sign_in user
  end

  describe "GET /schools" do
    it "should redirect to programme selection if programme not chosen" do
      get "/schools"

      expect(response).to redirect_to("/schools/choose-programme")
    end

    context "when the programme has been chosen" do
      before do
        cohort = create(:cohort, start_year: "2021")
        create(:school_cohort, cohort: cohort, school: user.induction_coordinator_profile.schools[0])
      end

      it "should render the dashboard when programme chosen" do
        get "/schools"

        expect(response).to render_template("schools/dashboard/show")
      end
    end
  end
end
