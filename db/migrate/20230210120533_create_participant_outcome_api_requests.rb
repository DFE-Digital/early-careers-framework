# frozen_string_literal: true

class CreateParticipantOutcomeApiRequests < ActiveRecord::Migration[6.1]
  def change
    create_table :participant_outcome_api_requests do |t|
      t.string :request_path
      t.integer :status_code
      t.jsonb :request_headers
      t.jsonb :request_body
      t.jsonb :response_body
      t.jsonb :response_headers
      t.references :participant_outcome, null: false, foreign_key: true, type: :uuid, index: { name: "index_participant_outcome_api_requests_on_participant_outcome" }

      t.timestamps
    end
  end
end
