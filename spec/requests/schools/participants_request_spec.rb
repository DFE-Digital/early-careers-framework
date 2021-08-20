# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Schools::Participants", type: :request do
  let(:user) { create(:user, :induction_coordinator, school_ids: [school.id]) }
  let(:school) { school_cohort.school }
  let(:cohort) { create(:cohort) }

  let!(:school_cohort) { create(:school_cohort, cohort: cohort) }
  let!(:another_cohort) { create(:school_cohort) }
  let(:mentor_profile) { create(:participant_profile, :mentor, school_cohort: school_cohort) }
  let!(:mentor_user) { mentor_profile.user }
  let!(:mentor_user_2) { create(:participant_profile, :mentor, school_cohort: school_cohort).user }
  let(:ect_profile) { create(:participant_profile, :ect, mentor_profile: mentor_user.mentor_profile, school_cohort: school_cohort) }
  let!(:ect_user) { ect_profile.user }
  let!(:withdrawn_ect) { create(:participant_profile, :ect, :withdrawn_record, school_cohort: school_cohort).user }
  let!(:unrelated_mentor) { create(:participant_profile, :mentor, school_cohort: another_cohort).user }
  let!(:unrelated_ect) { create(:participant_profile, :ect, school_cohort: another_cohort).user }

  before do
    FeatureFlag.activate(:induction_tutor_manage_participants)
    sign_in user
  end

  describe "GET /schools/:school_id/cohorts/:start_year/participants" do
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

      expect(response.body).to include(CGI.escapeHTML(ect_user.full_name))
      expect(response.body).to include(CGI.escapeHTML(mentor_user.full_name))
      expect(response.body).not_to include(CGI.escapeHTML(unrelated_mentor.full_name))
      expect(response.body).not_to include(CGI.escapeHTML(unrelated_ect.full_name))
    end

    it "does not list participants with withdrawn profile records" do
      get "/schools/#{school.slug}/cohorts/#{cohort.start_year}/participants"

      expect(response.body).not_to include(CGI.escapeHTML(withdrawn_ect.full_name))
    end

    context "when there are no mentors" do
      let(:other_school) { create(:school) }
      let(:other_cohort) { create(:cohort) }
      let!(:other_school_cohort) { create(:school_cohort, cohort: other_cohort, school: other_school) }
      let!(:ect_profile) { create(:participant_profile, :ect, school_cohort: other_school_cohort) }
      let(:user) { create(:user, :induction_coordinator, school_ids: [other_school.id]) }
      it "does not show the assign mentor link" do
        get "/schools/#{other_school.slug}/cohorts/#{other_cohort.start_year}/participants"

        expect(response.body).to include "No mentors added"
        expect(response.body).not_to include "Assign mentor"
      end
    end
  end

  describe "GET /schools/:school_id/cohorts/:start_year/participants/:id" do
    it "renders participant template" do
      get "/schools/#{school.slug}/cohorts/#{cohort.start_year}/participants/#{ect_profile.id}"

      expect(response).to render_template("schools/participants/show")
    end

    it "renders participant details" do
      get "/schools/#{school.slug}/cohorts/#{cohort.start_year}/participants/#{ect_profile.id}"

      expect(response.body).to include(CGI.escapeHTML(ect_user.full_name))
      expect(response.body).to include(CGI.escapeHTML(mentor_user.full_name))
    end
  end

  describe "GET /schools/:school_id/cohorts/:start_year/participants/:id/edit-mentor" do
    it "renders edit mentor template" do
      get "/schools/#{school.slug}/cohorts/#{cohort.start_year}/participants/#{ect_profile.id}/edit-mentor"

      expect(response).to render_template("schools/participants/edit_mentor")
    end

    it "renders correct mentors" do
      get "/schools/#{school.slug}/cohorts/#{cohort.start_year}/participants/#{ect_profile.id}/edit-mentor"

      expect(response.body).to include(CGI.escapeHTML(mentor_user.full_name))
      expect(response.body).not_to include(CGI.escapeHTML(unrelated_mentor.full_name))
    end
  end

  describe "PUT /schools/:school_id/cohorts/:start_year/participants/:id/update-mentor" do
    it "updates mentor" do
      params = { participant_mentor_form: { mentor_id: mentor_user_2.id } }
      put "/schools/#{school.slug}/cohorts/#{cohort.start_year}/participants/#{ect_profile.id}/update-mentor", params: params

      expect(response).to redirect_to(schools_participant_path(id: ect_profile))
      expect(flash[:success][:title]).to eq("Success")
      expect(ect_user.reload.early_career_teacher_profile.mentor).to eq(mentor_user_2)
    end

    it "shows error when a blank form is submitted" do
      ect_profile = create(:participant_profile, :ect, school_cohort: school_cohort)
      put "/schools/#{school.slug}/cohorts/#{cohort.start_year}/participants/#{ect_profile.id}/update-mentor"
      expect(response).to render_template("schools/participants/edit_mentor")
      expect(response.body).to include "Choose one"
    end
  end

  describe "GET /schools/:school_id/cohorts/:start_year/participants/:id/edit-name" do
    it "renders the edit name template with the correct name for an ECT" do
      get "/schools/#{school.slug}/cohorts/#{cohort.start_year}/participants/#{ect_profile.id}/edit-name"

      expect(response).to render_template("schools/participants/edit_name")
      expect(response.body).to include(CGI.escapeHTML(ect_user.full_name))
    end

    it "renders the edit name template with the correct name for a mentor" do
      get "/schools/#{school.slug}/cohorts/#{cohort.start_year}/participants/#{mentor_profile.id}/edit-name"

      expect(response).to render_template("schools/participants/edit_name")
      expect(response.body).to include(CGI.escapeHTML(mentor_user.full_name))
    end
  end

  describe "PUT /schools/:school_id/cohorts/:start_year/participants/:id/update-name" do
    it "updates the name of an ECT" do
      expect {
        put "/schools/#{school.slug}/cohorts/#{cohort.start_year}/participants/#{ect_profile.id}/update-name", params: {
          user: { full_name: "Joe Bloggs" },
        }
      }.to change { ect_user.reload.full_name }.to("Joe Bloggs")
    end

    it "updates the name of a mentor" do
      expect {
        put "/schools/#{school.slug}/cohorts/#{cohort.start_year}/participants/#{mentor_profile.id}/update-name", params: {
          user: { full_name: "Sally Mentor" },
        }
      }.to change { mentor_user.reload.full_name }.to("Sally Mentor")
    end

    it "rejects a blank name" do
      expect {
        put "/schools/#{school.slug}/cohorts/#{cohort.start_year}/participants/#{mentor_profile.id}/update-name", params: {
          user: { full_name: "" },
        }
      }.not_to change { mentor_user.reload.full_name }

      expect(response).to render_template("schools/participants/edit_name")
    end
  end

  describe "GET /schools/:school_id/cohorts/:start_year/participants/:id/edit-email" do
    it "renders the edit email template with the correct name for an ECT" do
      get "/schools/#{school.slug}/cohorts/#{cohort.start_year}/participants/#{ect_profile.id}/edit-email"

      expect(response).to render_template("schools/participants/edit_email")
      expect(response.body).to include(CGI.escapeHTML(ect_user.email))
    end

    it "renders the edit email template with the correct name for a mentor" do
      get "/schools/#{school.slug}/cohorts/#{cohort.start_year}/participants/#{mentor_profile.id}/edit-email"

      expect(response).to render_template("schools/participants/edit_email")
      expect(response.body).to include(CGI.escapeHTML(mentor_user.email))
    end
  end

  describe "PUT /schools/:school_id/cohorts/:start_year/participants/:id/update-email" do
    it "updates the email of an ECT" do
      expect {
        put "/schools/#{school.slug}/cohorts/#{cohort.start_year}/participants/#{ect_profile.id}/update-email", params: {
          user: { email: "new@email.com" },
        }
      }.to change { ect_user.reload.email }.to("new@email.com")
    end

    it "updates the email of a mentor" do
      expect {
        put "/schools/#{school.slug}/cohorts/#{cohort.start_year}/participants/#{mentor_profile.id}/update-email", params: {
          user: { email: "new@email.com" },
        }
      }.to change { mentor_user.reload.email }.to("new@email.com")
    end

    it "rejects a blank email" do
      expect {
        put "/schools/#{school.slug}/cohorts/#{cohort.start_year}/participants/#{mentor_profile.id}/update-email", params: {
          user: { email: "" },
        }
      }.not_to change { mentor_user.reload.email }
      expect(response).to render_template("schools/participants/edit_email")
    end

    it "rejects a malformed email" do
      expect {
        put "/schools/#{school.slug}/cohorts/#{cohort.start_year}/participants/#{mentor_profile.id}/update-email", params: {
          user: { email: "nonsense" },
        }
      }.not_to change { mentor_user.reload.email }
      expect(response).to render_template("schools/participants/edit_email")
    end

    it "rejects an email in use by another user" do
      other_user = create(:user)
      expect {
        put "/schools/#{school.slug}/cohorts/#{cohort.start_year}/participants/#{mentor_profile.id}/update-email", params: {
          user: { email: other_user.email },
        }
      }.not_to change { mentor_user.reload.email }
      expect(response).to redirect_to("/schools/#{school.slug}/cohorts/#{cohort.start_year}/participants/#{mentor_profile.id}/email-used")
    end
  end

  describe "GET /schools/:school_id/cohorts/:start_year/participants/:id/email-used" do
    it "renders the email used in same school template" do
      get "/schools/#{school.slug}/cohorts/#{cohort.start_year}/participants/#{ect_profile.id}/email-used"

      expect(response).to render_template("schools/participants/email_used")
    end
  end
end
