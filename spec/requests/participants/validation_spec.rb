# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Participant validations", with_feature_flags: { eligibility_notifications: "active" }, type: :request do
  let(:cohort) { Cohort.find_by(start_year: 2021) || create(:cohort, start_year: 2021) }
  let!(:new_cohort) { Cohort.find_by(start_year: 2022) || create(:cohort, start_year: 2022) }
  let!(:school_cohort) { create(:school_cohort, cohort:) }
  let!(:ect_profile) { create(:ect_participant_profile, school_cohort:) }
  let!(:ect_user) { ect_profile.user }
  let!(:mentor_profile) { create(:mentor_participant_profile, school_cohort:) }
  let!(:mentor_user) { mentor_profile.user }

  describe "starting the journey" do
    context "ECT is validating details" do
      before do
        sign_in ect_user
      end

      it "starts with :trn step" do
        get participants_validation_path
        expect(response).to redirect_to participants_validation_step_path(:trn)
      end

      context "current user is validating for previous cohort", travel_to: Date.new(2022, 12, 25) do
        it "does not raise an error when starting journey" do
          expect { get participants_validation_path }.not_to raise_error
        end
      end
    end

    context "Mentor is validating details" do
      before do
        sign_in mentor_user
      end

      it "starts with :check_given_trn step" do
        get participants_validation_path
        expect(response).to redirect_to participants_validation_step_path(:"check-trn-given")
      end
    end
  end

  Participants::ParticipantValidationForm.steps.each_key do |step|
    describe "#{step} step" do
      before do
        sign_in ect_user
        get participants_validation_path
        session_form = session[controller.class.session_key]
        session_form["dob"] = rand(20..30).years.ago + rand(1..355).days
        set_session controller.class.session_key, session_form
        get participants_validation_step_path(step.to_s.dasherize)
      end

      it "renders correct template" do
        expect(response).to render_template "participants/validations/#{step}"
      end
    end
  end
end
