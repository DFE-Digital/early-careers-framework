# frozen_string_literal: true

module Participants
  class SyncDQTInductionStartDate < BaseService
    FIRST_2021_ACADEMIC_DATE = Cohort::INITIAL_COHORT_START_DATE
    FIRST_2023_REGISTRATION_DATE = Cohort.find_by(start_year: 2023)&.registration_start_date || Date.new(2023, 6, 1)

    def initialize(dqt_induction_start_date, participant_profile)
      @dqt_induction_start_date = dqt_induction_start_date
      @participant_profile = participant_profile
    end

    def call
      return false unless update_induction_start_date
      return true if mentor? || pre_2021_dqt_induction_start_date?
      return cohort_missing unless target_cohort

      update_participant
    rescue StandardError
      false
    end

  private

    attr_reader :dqt_induction_start_date, :participant_profile

    delegate :latest_induction_record, :mentor?, to: :participant_profile
    delegate :cohort, to: :latest_induction_record, prefix: :participant

    def amend_cohort
      @amend_cohort ||= Induction::AmendParticipantCohort.new(participant_profile:,
                                                              source_cohort_start_year: participant_cohort.start_year,
                                                              target_cohort_start_year: target_cohort.start_year)
    end

    def clear_participant_sync_errors
      SyncDQTInductionStartDateError.where(participant_profile:).destroy_all
    end

    def cohort_missing
      save_error("Cohort containing date #{dqt_induction_start_date.to_fs(:govuk)} not setup in the service!")
    end

    def dqt_target_cohort
      @dqt_target_cohort ||= Cohort.for_induction_start_date(dqt_induction_start_date)
    end

    def pre_2021_dqt_induction_start_date?
      dqt_induction_start_date < FIRST_2021_ACADEMIC_DATE
    end

    def pre_2023_participant?
      participant_profile.created_at < FIRST_2023_REGISTRATION_DATE
    end

    def save_errors(*messages)
      messages.each do |message|
        SyncDQTInductionStartDateError.find_or_create_by!(participant_profile:, message:)
      end

      false
    end

    alias_method :save_error, :save_errors

    def target_cohort
      @target_cohort ||= dqt_target_cohort&.payments_frozen? ? participant_cohort : dqt_target_cohort
    end

    def update_induction_start_date
      participant_profile.update!(induction_start_date: dqt_induction_start_date) if dqt_induction_start_date
    end

    def update_participant
      clear_participant_sync_errors
      amend_cohort.save || save_errors(*amend_cohort.errors.full_messages)
    end
  end
end
