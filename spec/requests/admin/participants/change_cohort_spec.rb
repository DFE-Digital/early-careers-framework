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
      expect(response.body).to match(%r{<form.*action="/admin/participants/#{mentor_profile.id}/change_cohort"})
    end

    it "has the correct heading" do
      expect(response.body).to match(/Change #{mentor_profile.user.full_name}.* cohort/)
    end

    it "has a form with a select element and button" do
      expect(response.body).to match(/<select.*"induction_amend_participant_cohort\[target_cohort_start_year\]/)
      expect(response.body).to match(/<button.*class="govuk-button"/)
    end
  end

  describe "PUT /admin/participants/:participant_id/change_cohort/edit" do
    let(:params) { { induction_amend_participant_cohort: { target_cohort_start_year: 2022 } } }

    it "initializes an Induction::AmendParticipantCohort" do
      expect_any_instance_of(Induction::AmendParticipantCohort).to receive(:save).and_return(true)
      allow(Induction::AmendParticipantCohort).to receive(:new).and_call_original

      put("/admin/participants/#{mentor_profile.id}/change_cohort", params:)

      expect(Induction::AmendParticipantCohort).to have_received(:new).with(
        source_cohort_start_year: 2021,
        target_cohort_start_year: "2022", # string because this one is passed in from the form
        email: mentor_profile.user.email,
      )

      expect(response).to redirect_to(admin_participant_path(mentor_profile))
    end

    context "when there is an error" do
      let(:params) { { induction_amend_participant_cohort: { target_cohort_start_year: "a bad value" } } }

      it "displays the error summary and re-renders :edit" do
        put("/admin/participants/#{mentor_profile.id}/change_cohort", params:)

        expect(response.body).to include("Must be an integer")
      end
    end
  end
end
