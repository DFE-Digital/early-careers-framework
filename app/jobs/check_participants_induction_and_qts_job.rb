# frozen_string_literal: true

class CheckParticipantsInductionAndQtsJob < ApplicationJob
  def perform
    ects_with_no_induction_previous_induction_or_no_qts.find_each do |participant_profile|
      Participants::ParticipantValidationForm.call(participant_profile)
    end
  end

private

  def ects_with_no_induction_previous_induction_or_no_qts
    ParticipantProfile::ECT.joins(:ecf_participant_eligibility)
                           .where(ecf_participant_eligibility: { reason: %w[no_induction no_qts previous_induction], manually_validated: false })
  end
end
