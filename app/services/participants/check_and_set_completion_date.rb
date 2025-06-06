# frozen_string_literal: true

module Participants
  class CheckAndSetCompletionDate < BaseService
    IN_PROGRESS_STATUS = "InProgress"

    def call
      return unless participant_profile.ect?

      complete_induction if complete_induction?

      # TODO: TEMPORARILY PAUSE MOVING InProgress ECTS OUT OF THEIR FROZEN COHORT TO 2024
      # because the 'InProgress' status being reported by TRS (old DQT) since a few weeks now is no longer reliable:
      # old values of InProgress and NotYetCompleted (maybe some more) have been merged into InProgress, so some ECTs are
      # being now reported as continuing their induction but they have actually paused it (NotYetCompleted).
      # This trigger has move some of them (erroneously) to 2024.
      # We pause it to not extend the issue to other ECTs.
      #
      # TODO: Swap the comment in the next two lines of code to resume the trigger once TRS has fixed the issue

      # continue_training if sync_with_dqt && continue_training?
      sync_with_dqt

      record_completion_date_mismatch if completion_date_mismatch?
    end

  private

    attr_reader :participant_profile

    def initialize(participant_profile:)
      @participant_profile = participant_profile
    end

    def amend_cohort_to_continue_training
      @amend_cohort_to_continue_training ||=
        Induction::AmendParticipantCohort.new(participant_profile:,
                                              source_cohort_start_year:,
                                              target_cohort_start_year:,
                                              force_from_frozen_cohort: true).tap do
          participant_profile.reload
        end
    end

    def clear_participant_continue_training_errors
      ContinueTrainingCohortChangeError.where(participant_profile:).destroy_all
    end

    def complete_induction
      Induction::Complete.call(participant_profile:, completion_date:).tap { participant_profile.reload }
    end

    def complete_induction?
      !participant_completion_date && completion_date
    end

    def completion_date
      @completion_date ||= induction&.fetch("endDate", nil)
    end

    def completion_date_mismatch?
      participant_completion_date != completion_date
    end

    def continue_training
      clear_participant_continue_training_errors
      amend_cohort_to_continue_training.save || save_error(amend_cohort_to_continue_training.errors.full_messages.first)
    end

    def continue_training?
      in_progress_induction_status? && participant_profile.unfinished? && !esp_or_istip?
    end

    def esp_or_istip?
      [AppropriateBody.esp, AppropriateBody.istip].compact.include?(participant_profile.latest_induction_record.appropriate_body)
    end

    def induction
      @induction ||= DQT::GetInductionRecord.call(trn: participant_profile.teacher_profile.trn)
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

    def start_date
      @start_date ||= induction&.fetch("startDate", nil)
    end

    def sync_with_dqt
      Participants::SyncDQTInductionStartDate.call(start_date, participant_profile).tap { participant_profile.reload }
    end

    def target_cohort_start_year
      Cohort::DESTINATION_START_YEAR_FROM_A_FROZEN_COHORT
    end
  end
end
