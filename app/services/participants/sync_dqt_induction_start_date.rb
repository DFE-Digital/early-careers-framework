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

      current_induction_record = @participant_profile.induction_records.latest
      participant_cohort = current_induction_record.cohort
      dqt_cohort = Cohort.containing_date(@dqt_induction_start_date)
      return false if dqt_cohort.nil?

      if dqt_cohort == participant_cohort
        update_induction_start_date
        true
      else
        ActiveRecord::Base.transaction do
          amend_cohort = amend_cohort_form(dqt_cohort, participant_cohort)
          if amend_cohort.save
            update_induction_start_date
            delete_sync_error
            return true
          else
            save_error_message(amend_cohort)
            return false
          end
        end
      end
    end

    private

    def save_error_message(amend_cohort)
      SyncDqtInductionStartDateError.create!(participant_profile: @participant_profile,
                                             error_message: amend_cohort.errors.full_messages.join(", "))
    end

    def delete_sync_error
      SyncDqtInductionStartDateError.where(participant_profile: @participant_profile).destroy_all
    end

    def amend_cohort_form(dqt_cohort, participant_cohort)
      Induction::AmendParticipantCohort.new(participant_profile: @participant_profile,
                                            source_cohort_start_year: participant_cohort.start_year,
                                            target_cohort_start_year: dqt_cohort.start_year)
    end

    def update_induction_start_date
      @participant_profile.update!(induction_start_date: @dqt_induction_start_date)
    end
  end
end
