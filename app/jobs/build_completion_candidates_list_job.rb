# frozen_string_literal: true

# This job builds a list of candidates to check for an induction completion date
# The list will be processed by the SetParticipantCompletionDateJob
class BuildCompletionCandidatesListJob < ApplicationJob
  def perform
    Participants::BuildCompletionCandidateList.call
  rescue StandardError => e
    Rails.logger.error("BuildCompletionCandidatesListJob: #{e.message}")
  end
end
