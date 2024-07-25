# frozen_string_literal: true

module Participants
  class RetryContinueTraining < BaseService
    def call
      clear_participant_continue_training_errors
      return true unless unfinished_participant_continue_training?

      amend_cohort.save || save_error(amend_cohort.errors.full_messages.first)
    end

  private

    attr_reader :participant_profile

    def initialize(participant_profile:)
      @participant_profile = participant_profile
    end

    def amend_cohort
      @amend_cohort ||= Induction::AmendParticipantCohort.new(participant_profile:,
                                                              source_cohort_start_year:,
                                                              target_cohort_start_year:)
    end

    def clear_participant_continue_training_errors
      ContinueTrainingCohortChangeError.where(participant_profile:).destroy_all
    end

    def participant_cohort
      @participant_cohort ||= (participant_profile.schedule || participant_profile.latest_induction_record)&.cohort
    end

    def source_cohort_start_year
      participant_cohort&.start_year
    end

    def save_error(message)
      ContinueTrainingCohortChangeError.find_or_create_by!(participant_profile:, message:)

      false
    end

    def target_cohort
      @target_cohort ||= Cohort.active_registration_cohort
    end

    def target_cohort_start_year
      target_cohort.start_year
    end

    def unfinished_participant_continue_training?
      participant_profile.eligible_to_change_cohort_and_continue_training?(cohort: target_cohort)
    end
  end
end
