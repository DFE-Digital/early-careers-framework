# frozen_string_literal: true

class CheckParticipantsInductionJob < ApplicationJob
  def perform
    ects_with_no_induction_or_previous_induction.find_each do |participant_profile|
      Participants::ParticipantValidationForm.call(participant_profile)
    end
  end

private

  def ects_with_no_induction_or_previous_induction
    ParticipantProfile::ECT.joins(:ecf_participant_eligibility).merge(
      ECFParticipantEligibility.where(no_induction: true).or(ECFParticipantEligibility.where(previous_induction: true)),
    )
  end
end
