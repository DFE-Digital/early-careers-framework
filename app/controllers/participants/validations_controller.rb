# frozen_string_literal: true

module Participants
  class ValidationsController < BaseController
    include Multistep::Controller

    form Participants::ParticipantValidationForm, as: :validation_form
    setup_form do |form|
      form.participant_profile_id = current_user.teacher_profile.current_ecf_profile.id
      form.complete_step(:check_trn_given, check_trn_given: true) unless current_user.mentor?
    end

    abandon_journey_path { { action: :already_completed } }

    def no_trn
      form.complete_step(:trn, no_trn: true, trn: nil)
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

    def school_names_for_multi_school_mentor
      @school_names_for_multi_school_mentor ||= fetch_multi_school_names.join(" and ")
    end

    def partnership
      @partnership ||= school_cohort.school.partnerships.active.find_by(cohort: school_cohort.cohort)
    end

    def fetch_multi_school_names
      ParticipantProfile::Mentor
        .active_record
        .joins(:teacher_profile, :school_cohort)
        .where(teacher_profile: { trn: validation_form.participant_profile.teacher_profile.trn },
               school_cohort: { cohort_id: school_cohort.cohort_id })
        .where.not(id: validation_form.participant_profile.id)
        .map { |profile| profile.teacher_profile.school.name }
    end

    helper_method :school_cohort, :partnership, :school_names_for_multi_school_mentor
  end
end
