# frozen_string_literal: true

class ParticipantOutcomeApiRequest < ApplicationRecord
  belongs_to :participant_outcome, class_name: "ParticipantOutcome::NPQ"

  after_commit :push_to_big_query

private

  def push_to_big_query
    ParticipantOutcomes::StreamApiRequestsToBigQueryJob.perform_later(participant_outcome_api_request_id: id)
  end
end
