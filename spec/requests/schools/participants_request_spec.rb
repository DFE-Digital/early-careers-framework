# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Schools::Participants", type: :request do
  let(:user) { create(:user, :induction_coordinator) }
  let(:school) { user.induction_coordinator_profile.schools.first }
  # TODO: ?
  let(:cohort) { create(:cohort, start_year: 2021) }
  let!(:mentor_user) do
    user = create(:user, :mentor)
    user.mentor_profile.update!(school: school)
    user
  end
  let!(:mentor_user_2) do
    user = create(:user, :mentor)
    user.mentor_profile.update!(school: school)
    user
  end
  let!(:ect_user) do
    user = create(:user, :early_career_teacher)
    user.early_career_teacher_profile.update!(school: school, mentor_profile: mentor_user.mentor_profile)
    user
  end
  let!(:unrelated_mentor) { create(:user, :mentor) }
  let!(:unrelated_ect) { create(:user, :early_career_teacher) }

  before do
    sign_in user
  end

  describe "GET /schools/cohorts/:start_year/participants" do
    it "renders participants template" do
      get "/schools/cohorts/#{cohort.start_year}/participants"

      expect(response).to render_template("schools/participants/index")
    end

    it "renders participant details" do
      get "/schools/cohorts/#{cohort.start_year}/participants"

      expect(response.body).to include(CGI.escapeHTML(ect_user.full_name))
      expect(response.body).to include(CGI.escapeHTML(mentor_user.full_name))
      expect(response.body).not_to include(CGI.escapeHTML(unrelated_mentor.full_name))
      expect(response.body).not_to include(CGI.escapeHTML(unrelated_ect.full_name))
    end
  end

  describe "GET /schools/cohorts/:start_year/participants/:id" do
    it "renders participant template" do
      get "/schools/cohorts/#{cohort.start_year}/participants/#{ect_user.id}"

      expect(response).to render_template("schools/participants/show")
    end

    it "renders participant details" do
      get "/schools/cohorts/#{cohort.start_year}/participants/#{ect_user.id}"

      expect(response.body).to include(CGI.escapeHTML(ect_user.full_name))
      expect(response.body).to include(CGI.escapeHTML(mentor_user.full_name))
    end
  end

  describe "GET /schools/cohorts/:start_year/participants/:id/edit-details" do
    it "renders edit details template" do
      get "/schools/cohorts/#{cohort.start_year}/participants/#{ect_user.id}/edit-details"

      expect(response).to render_template("schools/participants/edit_details")
    end
  end

  describe "GET /schools/cohorts/:start_year/participants/:id/edit-mentor" do
    it "renders edit mentor template" do
      get "/schools/cohorts/#{cohort.start_year}/participants/#{ect_user.id}/edit-mentor"

      expect(response).to render_template("schools/participants/edit_mentor")
    end

    it "renders correct mentors" do
      get "/schools/cohorts/#{cohort.start_year}/participants/#{ect_user.id}/edit-mentor"

      expect(response.body).to include(CGI.escapeHTML(mentor_user.full_name))
      expect(response.body).not_to include(CGI.escapeHTML(unrelated_mentor.full_name))
    end
  end

  describe "PUT /schools/cohorts/:start_year/participants/:id" do
    it "updates mentor" do
      params = { participant_form: { mentor_id: mentor_user_2.id } }
      put "/schools/cohorts/#{cohort.start_year}/participants/#{ect_user.id}", params: params

      expect(response).to redirect_to(schools_cohort_participant_path(cohort.start_year, ect_user))
      expect(flash[:success][:title]).to eq("Success")
      # expect(ect_user.early_career_teacher_profile.mentor).to eq(mentor_user_2)
      expect(ect_user.reload.early_career_teacher_profile.mentor_profile).to eq(mentor_user_2.mentor_profile)
    end
  end
end
