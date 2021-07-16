# frozen_string_literal: true

module Schools
  class AddParticipantsController < ::Schools::BaseController
    include Multistep::Controller

    skip_after_action :verify_authorized
    before_action :set_school_cohort

    form AddParticipantForm, as: :add_participant_form
    result as: :participant_profile

    abandon_journey_path do
      @school_cohort.participants.any? ? schools_participants_path : schools_cohort_path
    end

    setup_form do |form|
      form.school_cohort_id = @school_cohort.id
      form.current_user_id = current_user.id
    end

  private

    def email_used_in_the_same_school?
      User.find_by(email: add_participant_form.email).school == add_participant_form.school_cohort.school
    end

    helper_method :email_used_in_the_same_school?
  end
end
