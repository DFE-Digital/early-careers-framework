# frozen_string_literal: true

# This is a job to update all of the induction completion dates from DQT for
# all of the 2021/2022 ECTs that do not currently have them.
# (see BuildCompletionCandidatesListJob for how the list is populated)
# It runs in batches of 200 as we have a 300 lookup per minute limit on the API
# This could get adapted later to be a regular running process with a bit more logic
class SetParticipantCompletionDateJob < ApplicationJob
  MAX_CANDIDATES = 200

  def perform
    CompletionCandidate.limit(MAX_CANDIDATES).each do |candidate|
      Participants::CheckAndSetCompletionDate.call(participant_profile: candidate.participant_profile)
      candidate.destroy!
    end
  rescue StandardError => e
    Rails.logger.error("SetParticipantCompletionDateJob: #{e.message}")
  end
end
