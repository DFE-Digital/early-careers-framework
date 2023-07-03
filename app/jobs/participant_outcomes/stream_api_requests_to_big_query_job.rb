# frozen_string_literal: true

module ParticipantOutcomes
  class StreamApiRequestsToBigQueryJob < ApplicationJob
    queue_as :big_query

    def perform(participant_outcome_api_request_id:)
      return if table.nil?

      api_request = ParticipantOutcomeApiRequest.find(participant_outcome_api_request_id)

      rows = [
        {
          participant_outcome_api_request_id: api_request.id,
          request_path: api_request.request_path,
          status_code: api_request.status_code,
          request_headers: api_request.request_headers.to_json,
          request_body: api_request.request_body.to_json,
          response_body: api_request.response_body.to_json,
          response_headers: api_request.response_headers.to_json,
          participant_outcome_id: api_request.participant_outcome_id,
          created_at: api_request.created_at,
          updated_at: api_request.updated_at,
        }.stringify_keys,
      ]

      table.insert(rows, ignore_unknown: true)
    end

    def table
      bigquery = Google::Cloud::Bigquery.new
      dataset = bigquery.dataset "npq_participant_outcomes", skip_lookup: true
      dataset.table "npq_participant_outcome_api_requests_#{Rails.env.downcase}"
    end
  end
end
