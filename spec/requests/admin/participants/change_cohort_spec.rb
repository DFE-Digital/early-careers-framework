# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Admin::Participants", :with_default_schedules, type: :request do
  let(:admin_user) { create(:user, :admin) }

  let!(:mentor_profile)               { create :mentor }
  let!(:ect_profile)                  { create :ect, mentor_profile_id: mentor_profile.id }

  before { sign_in(admin_user) }

  describe "GET /admin/participants/:participant_id/change_cohort/edit" do
    before { get("/admin/participants/#{mentor_profile.id}/change_cohort/edit") }

    it "renders the edit form for a participant's cohort" do
      expect(response).to render_template("admin/participants/change_cohort/edit")
    end

    it "has the correct heading" do
      expect(response.body).to match(/Select #{mentor_profile.user.full_name}.* new cohort/)
    end
  end

  describe "PUT /admin/participants/:participant_id/change_cohort/edit" do
    let(:params) { { induction_amend_participant_cohort: { target_cohort_start_year: 2022 } } }

    it "initializes an Induction::AmendParticipantCohort" do
      allow(Induction::AmendParticipantCohort).to receive(:new).and_call_original

      put("/admin/participants/#{mentor_profile.id}/change_cohort", params:)

      expect(Induction::AmendParticipantCohort).to have_received(:new).with(
        source_cohort_start_year: 2021,
        target_cohort_start_year: "2022", # string because this one is passed in from the form
        email: mentor_profile.user.email,
      )
    end

    context "when there is an error" do
      it "displays the error summary and re-renders :edit"
    end
  end
end
