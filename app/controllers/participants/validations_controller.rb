# frozen_string_literal: true

module Participants
  class ValidationsController < BaseController
    include Multistep::Controller

    form Participants::ParticipantValidationForm, as: :validation_form

    setup_form do |form|
      form.participant_profile_id = current_user.participant_profiles.active_record.ecf.first.id
    end

    abandon_journey_path { { action: :already_completed } }

    def no_trn
      validation_form.no_trn = true
      validation_form.trn = nil
      form.record_completed_step :trn
      store_form_in_session
      redirect_to action: :show, step: step_param(validation_form.next_step)
    end

    def already_completed
      render :complete
    end

  private

    def school_cohort
      @school_cohort ||= validation_form.participant_profile.school_cohort
    end
    helper_method :school_cohort
  end
end
