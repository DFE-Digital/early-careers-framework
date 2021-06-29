# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Schools::Participants", type: :request do
  let(:user) { create(:user, :induction_coordinator) }
  let(:school) { user.induction_coordinator_profile.schools.first }
  let(:cohort) { create(:cohort) }
  let!(:school_cohort) { create(:school_cohort, school: school, cohort: cohort) }

  let!(:mentor_profile) { create :participant_profile, :mentor, school: school }
  let!(:mentor_profile_2) { create :participant_profile, :mentor, school: school }
  let!(:ect_profile) { create :participant_profile, :ect, school: school, mentor_profile: mentor_profile }

  let!(:unrelated_mentor_profile) { create :participant_profile, :mentor }
  let!(:unrelated_ect_profile) { create :participant_profile, :ect }

  before do
    FeatureFlag.activate(:induction_tutor_manage_participants)
    sign_in user
  end

  describe "GET /schools/cohorts/:start_year/participants" do
    it "shouldn't be available when feature flag turned off" do
      FeatureFlag.deactivate(:induction_tutor_manage_participants)
      expect {
        get "/schools/cohorts/#{cohort.start_year}/participants"
      }.to raise_error(ActionController::RoutingError)
    end

    it "renders participants template" do
      get "/schools/#{school.slug}/cohorts/#{cohort.start_year}/participants"

      expect(response).to render_template("schools/participants/index")
    end

    it "renders participant details" do
      get "/schools/#{school.slug}/cohorts/#{cohort.start_year}/participants"

      expect(response.body).to include(CGI.escapeHTML(ect_profile.user.full_name))
      expect(response.body).to include(CGI.escapeHTML(mentor_profile.user.full_name))
      expect(response.body).not_to include(CGI.escapeHTML(unrelated_mentor_profile.user.full_name))
      expect(response.body).not_to include(CGI.escapeHTML(unrelated_ect_profile.user.full_name))
    end
  end

  describe "GET /schools/cohorts/:start_year/participants/:id" do
    it "renders participant template" do
      get "/schools/#{school.slug}/cohorts/#{cohort.start_year}/participants/#{ect_profile.user.id}"

      expect(response).to render_template("schools/participants/show")
    end

    it "renders participant details" do
      get "/schools/#{school.slug}/cohorts/#{cohort.start_year}/participants/#{ect_profile.user.id}"

      expect(response.body).to include(CGI.escapeHTML(ect_profile.user.full_name))
      expect(response.body).to include(CGI.escapeHTML(mentor_profile.user.full_name))
    end
  end

  describe "GET /schools/cohorts/:start_year/participants/:id/edit-mentor" do
    it "renders edit mentor template" do
      get "/schools/#{school.slug}/cohorts/#{cohort.start_year}/participants/#{ect_profile.user.id}/edit-mentor"

      expect(response).to render_template("schools/participants/edit_mentor")
    end

    it "renders correct mentors" do
      get "/schools/#{school.slug}/cohorts/#{cohort.start_year}/participants/#{ect_profile.user.id}/edit-mentor"

      expect(response.body).to include(CGI.escapeHTML(mentor_profile.user.full_name))
      expect(response.body).not_to include(CGI.escapeHTML(unrelated_mentor_profile.user.full_name))
    end
  end

  describe "PUT /schools/cohorts/:start_year/participants/:id/update-mentor" do
    it "updates mentor" do
      params = { participant_mentor_form: { mentor_id: mentor_profile_2.user_id } }
      put "/schools/#{school.slug}/cohorts/#{cohort.start_year}/participants/#{ect_profile.user.id}/update-mentor", params: params

      expect(response).to redirect_to(schools_participant_path(id: ect_profile.user_id))
      expect(flash[:success][:title]).to eq "Success"
      expect(ect_profile.reload.mentor_profile_id).to eq mentor_profile_2.id
    end
  end
end
