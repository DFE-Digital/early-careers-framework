# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Schools::Dashboard", type: :request do
  let(:user) { create(:user, :induction_coordinator) }
  let(:school) { user.schools.first }

  before do
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

      expect(response).to redirect_to("/schools/#{school.slug}/cohorts/#{cohort.start_year}/choose-programme")
    end

    it "should redirect to programme selection if programme not chosen" do
      # Also test the redirect in the base controller
      get "/schools/#{school.slug}/cohorts/#{cohort.start_year}/programme-choice"

      expect(response).to redirect_to("/schools/#{school.slug}/cohorts/#{cohort.start_year}/choose-programme")
    end

    context "when the programme has been chosen" do
      before do
        create(:school_cohort, cohort: cohort, school: user.induction_coordinator_profile.schools[0])
      end

      it "should render the dashboard" do
        get "/schools/#{school.slug}"

        expect(response).to render_template("schools/dashboard/show")
      end

      context "when a provider has withdrawn an ect" do
        it "renders a list of withdrawn ects on the dashboard" do
          school_cohort = school.school_cohorts[0]
          ect = create(:participant_profile, :ecf_participant_eligibility, :ect, training_status: "withdrawn", school_cohort: school_cohort)
          cohort = create(:cohort, :current)
          delivery_partner = create(:delivery_partner, name: "Delivery Partner")
          lead_provider = create(:lead_provider, name: "Lead Provider", cohorts: [cohort])
          create(:partnership, school: school, lead_provider: lead_provider, delivery_partner: delivery_partner, cohort: cohort)

          get "/schools/#{school.slug}"
          expect(response).to render_template("schools/dashboard/show")
          expect(response.body).to include(CGI.escapeHTML(ect.user.full_name))
          expect(response.body).to include(CGI.escapeHTML(delivery_partner.name))
          expect(response.body).to include(CGI.escapeHTML(lead_provider.name))
        end
      end
    end
  end
end
