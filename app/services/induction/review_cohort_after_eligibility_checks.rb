# frozen_string_literal: true

# Change the cohort of an ECF participant whose eligibility has been recalculated.
# If the participant has become eligible and is currently in a payments-frozen cohort,
# transfer them to the currently active registration cohort.
module Induction
  class ReviewCohortAfterEligibilityChecks
    include ActiveModel::Model

    attr_accessor :participant_profile

    def call
      amend_participant_cohort if eligible_participant_in_frozen_cohort?
    end

  private

    def amend_participant_cohort
      Induction::AmendParticipantCohort.new(participant_profile:,
                                            source_cohort_start_year: participant_profile.schedule&.cohort.start_year,
                                            target_cohort_start_year: Cohort.active_registration_cohort.start_year)
                                       .save
    end

    def eligible_participant_in_frozen_cohort?
      return false unless participant_profile.eligible?
      return false if participant_profile.ecf_participant_eligibility&.reason != "none"

      participant_profile.schedule&.cohort&.payments_frozen?
    end
  end
end
