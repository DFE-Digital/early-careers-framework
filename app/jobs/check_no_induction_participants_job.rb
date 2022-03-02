# frozen_string_literal: true

class CheckNoInductionParticipantsJob < ApplicationJob
  def perform
    ECFParticipantEligibility.where(no_induction: true).find_each do |eligibility|
      Participants::ParticipantValidationForm.call(eligibility.participant_profile)
    end
  end
end
