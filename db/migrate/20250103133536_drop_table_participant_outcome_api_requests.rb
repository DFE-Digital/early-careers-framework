# frozen_string_literal: true

class DropTableParticipantOutcomeApiRequests < ActiveRecord::Migration[7.1]
  def up
    drop_table :participant_outcome_api_requests
  end

  def down
    create_table :participant_outcome_api_requests, id: :uuid, default: -> { "gen_random_uuid()" } do |t|
      t.string   :request_path
      t.integer  :status_code
      t.jsonb    :request_headers
      t.jsonb    :request_body
      t.jsonb    :response_body
      t.jsonb    :response_headers
      t.uuid     :participant_outcome_id, null: false
      t.datetime :created_at,             null: false
      t.datetime :updated_at,             null: false

      t.index :participant_outcome_id, name: "index_participant_outcome_api_requests_on_participant_outcome"
    end
  end
end
