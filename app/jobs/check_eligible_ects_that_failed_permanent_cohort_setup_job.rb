# frozen_string_literal: true

class CheckEligibleEctsThatFailedPermanentCohortSetupJob < ApplicationJob
  def perform
    ect_errors.find_each do |error|
      ect = error.participant_profile
      Participants::SyncDQTInductionStartDate.call(ect.induction_start_date, ect)
    end
  end

private

  def ect_errors
    SyncDQTInductionStartDateError.joins(participant_profile: :ecf_participant_eligibility)
                                  .where(ecf_participant_eligibilities: { status: :eligible })
  end
end
