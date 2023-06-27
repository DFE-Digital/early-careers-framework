# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Admin::Participants", type: :request do
  let(:scenario) { NewSeeds::Scenarios::Users::AdminUser.new.build.with_super_user }

  let(:admin_user) { scenario.user }
  let(:user) { create :user, full_name: "Elza Smith" }
  let!(:mentor_profile) { create :mentor, user: }
  let!(:ect_profile) { create :ect, mentor_profile_id: mentor_profile.id }

  before { sign_in(admin_user) }

  describe "GET /admin/participants/:participant_id/change_cohort/edit" do
    context "when being a super user admin" do
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

    context "when being a standard admin user" do
      let(:scenario) { NewSeeds::Scenarios::Users::AdminUser.new.build }

      it "raises an forbidden exception" do
        expect { get("/admin/participants/#{mentor_profile.id}/change_cohort/edit") }.to raise_error(Pundit::NotAuthorizedError)
      end
    end
  end

  describe "PUT /admin/participants/:participant_id/change_cohort" do
    let(:next_cohort) { Cohort.next || create(:cohort, :next) }
    let(:params) { { induction_amend_participant_cohort: { target_cohort_start_year: next_cohort.start_year } } }

    context "when being a super user admin" do
      it "initializes an Induction::AmendParticipantCohort" do
        expect_any_instance_of(Induction::AmendParticipantCohort).to receive(:save).and_return(true)
        allow(Induction::AmendParticipantCohort).to receive(:new).and_call_original

        put("/admin/participants/#{mentor_profile.id}/change_cohort", params:)

        expect(Induction::AmendParticipantCohort).to have_received(:new).with(
          source_cohort_start_year: Cohort.current.start_year,
          target_cohort_start_year: next_cohort.display_name, # string because this one is passed in from the form
          participant_profile: mentor_profile,
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

    context "when being a standard admin user" do
      let(:scenario) { NewSeeds::Scenarios::Users::AdminUser.new.build }

      it "raises an forbidden exception" do
        expect { put("/admin/participants/#{mentor_profile.id}/change_cohort", params:) }.to raise_error(Pundit::NotAuthorizedError)
      end
    end
  end
end
