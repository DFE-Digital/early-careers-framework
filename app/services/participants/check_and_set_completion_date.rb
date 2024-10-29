# frozen_string_literal: true

module Participants
  class CheckAndSetCompletionDate < BaseService
    IN_PROGRESS_STATUS = "InProgress"

    def call
      return unless participant_profile.ect?

      complete_induction if complete_induction?
      continue_training if sync_with_dqt && continue_training?
      record_completion_date_mismatch if completion_date_mismatch?
    end

  private

    attr_reader :participant_profile

    def initialize(participant_profile:)
      @participant_profile = participant_profile
    end

    def amend_cohort_to_continue_training
      @amend_cohort_to_continue_training ||= Induction::AmendParticipantCohort.new(participant_profile:,
                                                                                   source_cohort_start_year:,
                                                                                   target_cohort_start_year:,
                                                                                   force_from_frozen_cohort: true)
    end

    def clear_participant_continue_training_errors
      ContinueTrainingCohortChangeError.where(participant_profile:).destroy_all
    end

    def complete_induction
      Induction::Complete.call(participant_profile:, completion_date:)
    end

    def complete_induction?
      !participant_completion_date && completion_date
    end

    # Get the latest induction period endDate if induction endDate comes with a value.
    # i.e. induction endDate field value presence flags the latest period is actually the last one.
    def completion_date
      @completion_date ||= induction&.fetch("endDate", nil).presence &&
        induction_periods.map { |period| period["endDate"] }.compact.max
    end

    def completion_date_mismatch?
      participant_completion_date != completion_date
    end

    def continue_training
      clear_participant_continue_training_errors
      amend_cohort_to_continue_training.save || save_error(amend_cohort_to_continue_training.errors.full_messages.first)
    end

    def continue_training?
      in_progress_induction_status? && participant_cohort&.payments_frozen?
    end

    def induction
      @induction ||= DQT::GetInductionRecord.call(trn: participant_profile.teacher_profile.trn)
    end

    def induction_periods
      @induction_periods ||= Array(induction&.dig("periods"))
    end

    def in_progress_induction_status?
      induction&.dig("status") == IN_PROGRESS_STATUS
    end

    def participant_cohort
      (participant_profile.schedule || participant_profile.latest_induction_record)&.cohort
    end

    def participant_completion_date
      participant_profile.induction_completion_date
    end

    def record_completion_date_mismatch
      ParticipantProfileCompletionDateInconsistency.upsert(
        {
          participant_profile_id: participant_profile.id,
          dqt_value: completion_date,
          participant_value: participant_completion_date,
        },
        unique_by: :participant_profile_id,
      )
    end

    def save_error(message)
      ContinueTrainingCohortChangeError.find_or_create_by!(participant_profile:, message:)

      false
    end

    def source_cohort_start_year
      participant_cohort&.start_year
    end

    # returns the minimum start date of all the induction periods
    def start_date
      @start_date ||= induction_periods.map { |period| period["startDate"] }.compact.min
    end

    def sync_with_dqt
      Participants::SyncDQTInductionStartDate.call(start_date, participant_profile)
    end

    def target_cohort
      Cohort.active_registration_cohort
    end

    # target_cohort_start_year
    delegate :start_year, to: :target_cohort, prefix: true
  end
end
