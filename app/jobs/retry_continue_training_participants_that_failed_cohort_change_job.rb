# frozen_string_literal: true

class RetryContinueTrainingParticipantsThatFailedCohortChangeJob < ApplicationJob
  def perform
    errors.find_each do |error|
      Participants::RetryContinueTraining.call(participant_profile: error.participant_profile)
    end
  end

private

  def errors
    ContinueTrainingCohortChangeError.includes(participant_profile: { schedule: :cohort })
  end
end
