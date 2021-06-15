# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Schools::ChooseProgramme", type: :request do
  let(:user) { create(:user, :induction_coordinator) }
  let(:school) { user.induction_coordinator_profile.schools.first }
  let(:cohort) { create(:cohort, start_year: 2021) }

  before do
    cohort
    sign_in user
  end

  describe "GET /schools/choose-programme" do
    it "renders the choose programme template" do
      get "/schools/#{school.id}/choose-programme"

      expect(response).to render_template("schools/choose_programme/show")
    end

    context "when the school has chosen provision" do
      before do
        SchoolCohort.create!(school: school, cohort: cohort, induction_programme_choice: "full_induction_programme")
      end

      it "redirects to the dashboard" do
        get "/schools/#{school.id}/choose-programme"

        expect(response).to redirect_to("/schools/#{school.id}")
      end
    end
  end

  describe "GET /schools/choose-programme/advisory" do
    it "renders the choose programme advisory template" do
      get "/schools/#{school.id}/choose-programme/advisory"

      expect(response).to render_template("schools/choose_programme/advisory")
    end

    context "when the school has chosen provision" do
      before do
        SchoolCohort.create!(school: school, cohort: cohort, induction_programme_choice: "full_induction_programme")
      end

      it "redirects to the dashboard" do
        get "/schools/#{school.id}/choose-programme/advisory"

        expect(response).to redirect_to("/schools/#{school.id}")
      end
    end
  end

  describe "POST /schools/choose-programme" do
    it "should show an error if nothing is selected" do
      post "/schools/#{school.id}/choose-programme", params: { induction_choice_form: { programme_choice: "" } }

      expect(response).to render_template("schools/choose_programme/show")
      expect(response.body).to include("Select how you want to run your induction")
    end

    it "should redirect to confirmation page" do
      induction_programme_choice = "full_induction_programme"
      post "/schools/#{school.id}/choose-programme", params: { induction_choice_form: { programme_choice: induction_programme_choice } }
      expect(response).to redirect_to(action: :confirm_programme)
    end
  end

  describe "GET /schools/:school_id/choose-programme/confirm-programme" do
    it "should render the show template when selecting FIP" do
      induction_programme_choice = "full_induction_programme"
      post "/schools/#{school.id}/choose-programme", params: { induction_choice_form: { programme_choice: induction_programme_choice } }
      get "/schools/#{school.id}/choose-programme/confirm-programme"

      expect(response).to render_template(:confirm_programme)
      expect(response.body).to include("Use an approved training provider")
    end

    it "should render the show template when selecting CIP" do
      induction_programme_choice = "core_induction_programme"
      post "/schools/#{school.id}/choose-programme", params: { induction_choice_form: { programme_choice: induction_programme_choice } }
      get "/schools/#{school.id}/choose-programme/confirm-programme"

      expect(response).to render_template(:confirm_programme)
      expect(response.body).to include("Use DfE accredited materials")
    end
  end

  describe "POST /schools/choose-programme/save-programme" do
    it "should store the induction choice" do
      induction_programme_choice = "full_induction_programme"
      expect {
        post "/schools/#{school.id}/choose-programme/save-programme", params: { induction_choice_form: { programme_choice: induction_programme_choice } }
      }.to change { SchoolCohort.count }.by(1)
      expect(response).to redirect_to(action: :success)
    end
  end

  describe "GET /schools/choose-programme/success" do
    it "should render the success template" do
      get "/schools/#{school.id}/choose-programme/success"

      expect(response).to render_template(:success)
    end
  end
end
