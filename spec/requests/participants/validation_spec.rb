# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Participant validations", with_feature_flags: { eligibility_notifications: "active" }, type: :request do
  before do
    sign_in user
  end

  let(:school_cohort) { create(:school_cohort) }
  let(:profile) { create(:ect_participant_profile, school_cohort: school_cohort) }
  let(:user) { profile.user }

  describe "starting the journey"

  it "starts with :trn step" do
    get participants_validation_path
    expect(response).to redirect_to participants_validation_step_path(:trn)
  end

  Participants::ParticipantValidationForm.steps.each_key do |step|
    describe "#{step} step" do
      before do
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
