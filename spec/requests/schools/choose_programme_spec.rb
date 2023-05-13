# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Schools::ChooseProgramme", :with_default_schedules, type: :request do
  let(:user) { create(:user, :induction_coordinator) }
  let(:school) { user.induction_coordinator_profile.schools.first }
  let(:cohort) { Cohort.find_by(start_year: 2021) || create(:cohort, start_year: 2021) }

  before do
    sign_in user
  end

  describe "GET /schools/choose-programme" do
    it "renders the choose programme template" do
      get "/schools/#{school.slug}/cohorts/#{cohort.start_year}/choose-programme"

      expect(response).to render_template("schools/choose_programme/show")
    end

    context "when the school has chosen provision" do
      let(:cohort) { Cohort.current || create(:cohort, :current) }

      before do
        SchoolCohort.create!(school:, cohort:, induction_programme_choice: "full_induction_programme")
      end

      it "redirects to the dashboard" do
        get "/schools/#{school.slug}/cohorts/#{cohort.start_year}/choose-programme"
        follow_redirect!
        expect(response).to redirect_to("/schools/#{school.slug}#_#{cohort.description.parameterize}")
      end
    end
  end

  describe "POST /schools/choose-programme" do
    it "should show an error if nothing is selected" do
      post "/schools/#{school.slug}/cohorts/#{cohort.start_year}/choose-programme", params: { induction_choice_form: { programme_choice: "" } }

      expect(response).to render_template("schools/choose_programme/show")
      expect(response.body).to include("Select how you want to run your induction")
    end

    it "should redirect to confirmation page" do
      induction_programme_choice = "full_induction_programme"
      post "/schools/#{school.slug}/cohorts/#{cohort.start_year}/choose-programme", params: { induction_choice_form: { programme_choice: induction_programme_choice } }
      expect(response).to redirect_to(action: :confirm_programme)
    end
  end

  describe "GET /schools/:school_id/choose-programme/confirm-programme" do
    it "should render the show template when selecting FIP" do
      induction_programme_choice = "full_induction_programme"
      post "/schools/#{school.slug}/cohorts/#{cohort.start_year}/choose-programme", params: { induction_choice_form: { programme_choice: induction_programme_choice } }
      get "/schools/#{school.slug}/cohorts/#{cohort.start_year}/choose-programme/confirm-programme"

      expect(response).to render_template(:confirm_programme)
      expect(response.body).to include I18n.t("schools.induction_choice_form.confirmation_options.#{induction_programme_choice}")
    end

    it "should render the show template when selecting CIP" do
      induction_programme_choice = "core_induction_programme"
      post "/schools/#{school.slug}/cohorts/#{cohort.start_year}/choose-programme", params: { induction_choice_form: { programme_choice: induction_programme_choice } }
      get "/schools/#{school.slug}/cohorts/#{cohort.start_year}/choose-programme/confirm-programme"

      expect(response).to render_template(:confirm_programme)
      expect(response.body).to include I18n.t("schools.induction_choice_form.confirmation_options.#{induction_programme_choice}")
    end
  end

  describe "GET /schools/choose-programme/success" do
    it "should render the success template" do
      get "/schools/#{school.slug}/cohorts/#{cohort.start_year}/choose-programme/success"

      expect(response).to render_template(:success)
    end
  end
end
