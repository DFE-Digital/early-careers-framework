# frozen_string_literal: true

module ParticipantOutcomes
  class StreamBigQueryJob < ApplicationJob
    queue_as :big_query

    def perform(participant_outcome_id:)
      bigquery = Google::Cloud::Bigquery.new
      dataset = bigquery.dataset "npq_participant_outcomes", skip_lookup: true
      table = dataset.table "npq_participant_outcomes_#{Rails.env.downcase}"
      return if table.nil?

      outcome = ParticipantOutcome::NPQ.find(participant_outcome_id)
      rows = [
        {
          participant_outcome_id: outcome.id,
          state: outcome.state,
          completion_date: outcome.completion_date,
          participant_declaration_id: outcome.participant_declaration_id,
          created_at: outcome.created_at,
          updated_at: outcome.updated_at,
          qualified_teachers_api_request_successful: outcome.qualified_teachers_api_request_successful,
          sent_to_qualified_teachers_api_at: outcome.sent_to_qualified_teachers_api_at,
        }.stringify_keys,
      ]

      table.insert(rows, ignore_unknown: true)
    end
  end
end
