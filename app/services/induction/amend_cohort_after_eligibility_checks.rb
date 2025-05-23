# frozen_string_literal: true

# Change the cohort of an ECF participant whose eligibility has been recalculated.
# If the participant has become eligible and is currently in a payments-frozen cohort,
# transfer them to the currently active registration cohort.
module Induction
  class AmendCohortAfterEligibilityChecks
    include ActiveModel::Model

    attr_accessor :participant_profile

    def call
      amend_participant_cohort if unfinished_eligible_participant?
    end

  private

    def amend_participant_cohort
      Induction::AmendParticipantCohort.new(participant_profile:,
                                            source_cohort_start_year: participant_profile.schedule&.cohort&.start_year,
                                            target_cohort_start_year: Cohort::DESTINATION_START_YEAR_FROM_A_FROZEN_COHORT,
                                            force_from_frozen_cohort: true)
                                       .save
    end

    def unfinished_eligible_participant?
      return false unless participant_profile.eligible?
      return false if participant_profile.ecf_participant_eligibility&.reason != "none"

      participant_profile.unfinished?
    end
  end
end
