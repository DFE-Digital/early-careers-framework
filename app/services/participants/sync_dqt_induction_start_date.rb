# frozen_string_literal: true

module Participants
  class SyncDqtInductionStartDate < BaseService
    def initialize(dqt_induction_start_date, participant_profile)
      @dqt_induction_start_date = dqt_induction_start_date
      @participant_profile = participant_profile
    end

    def call
      return false unless FeatureFlag.active?(:cohortless_dashboard)
      return false unless dqt_induction_start_date
      return update_induction_start_date if mentor? || Cohort.valid_early_rollout_date?(dqt_induction_start_date) || pre_cohortless_registration_participant?
      return cohort_missing unless target_cohort

      update_participant
    rescue StandardError
      false
    end

  private

    attr_reader :dqt_induction_start_date, :participant_profile

    delegate :current_induction_record, :mentor?, to: :participant_profile
    delegate :cohort, to: :current_induction_record, prefix: :participant

    def amend_cohort
      @amend_cohort ||= Induction::AmendParticipantCohort.new(participant_profile:,
                                                              source_cohort_start_year: participant_cohort.start_year,
                                                              target_cohort_start_year: target_cohort.start_year)
    end

    def clear_participant_sync_errors
      SyncDqtInductionStartDateError.where(participant_profile:).destroy_all
    end

    def pre_cohortless_registration_participant?
      participant_profile.created_at < Cohort::COHORTLESS_RELEASE_DATE
    end

    def save_errors(*messages)
      messages.each do |message|
        SyncDqtInductionStartDateError.find_or_create_by!(participant_profile:, message:)
      end

      false
    end
    alias_method :save_error, :save_errors

    def target_cohort
      @target_cohort ||= Cohort.containing_date(dqt_induction_start_date)
    end

    def cohort_missing
      save_error("Cohort containing date #{dqt_induction_start_date.to_s(:govuk)} not setup in the service!")
    end

    def update_induction_start_date
      participant_profile.update!(induction_start_date: dqt_induction_start_date)
    end

    def update_participant
      clear_participant_sync_errors
      amend_cohort.save ? update_induction_start_date : save_errors(*amend_cohort.errors.full_messages)
    end
  end
end
