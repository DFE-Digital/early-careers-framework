# frozen_string_literal: true

module Participants
  class SyncDqtInductionStartDate < BaseService
    def initialize(dqt_induction_start_date, participant_profile)
      @dqt_induction_start_date = dqt_induction_start_date
      @participant_profile = participant_profile
    end

    def call
      return false unless FeatureFlag.active?(:cohortless_dashboard)
      return false if @dqt_induction_start_date.nil?
      return false if @participant_profile.induction_start_date.present?

      # Get participant profile cohort and DQT cohort
      current_induction_record = @participant_profile.current_induction_record
      participant_cohort = current_induction_record.cohort
      dqt_cohort = Cohort.containing_date(@dqt_induction_start_date)
      return false if dqt_cohort.nil?

      # check cohort against DQT induction start date
      if dqt_cohort == participant_cohort
        @participant_profile.update!(induction_start_date: @dqt_induction_start_date)
        true
      else
        ActiveRecord::Base.transaction do
          # change participant cohort
          source_cohort_start_year = participant_cohort.start_year
          target_cohort_start_year = dqt_cohort.start_year
          amend_cohort = Induction::AmendParticipantCohort.new(participant_profile: @participant_profile, source_cohort_start_year:, target_cohort_start_year:)
          if amend_cohort.save
            @participant_profile.update!(induction_start_date: @dqt_induction_start_date)
            # update participant profile flag
            return true
            # else
            # flag participant (and save error message amend_cohort.errors?)
          end
        end
      end
    end
  end
end
