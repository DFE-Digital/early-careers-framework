# frozen_string_literal: true

module ParticipantOutcomes
  class StreamBigQueryJob < ApplicationJob
    queue_as :participant_outcomes

    def perform(participant_outcome_id:)
      bigquery = Google::Cloud::Bigquery.new
      dataset = bigquery.dataset "npq_participant_outcomes", skip_lookup: true
      table = dataset.table "npq_participant_outcomes_#{Rails.env.downcase}", skip_lookup: true
      outcome = ParticipantOutcome::NPQ.find(participant_outcome_id)

      rows = [
        {
          participant_outcome_id: outcome.id,
          state: outcome.state,
          completion_date: outcome.completion_date,
          participant_declaration_id: outcome.participant_declaration_id,
          created_at: outcome.created_at,
          updated_at: outcome.updated_at,
        }.stringify_keys,
      ]

      table.insert(rows, ignore_unknown: true)
    end
  end
end
