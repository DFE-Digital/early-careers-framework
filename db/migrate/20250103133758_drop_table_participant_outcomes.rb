# frozen_string_literal: true

class DropTableParticipantOutcomes < ActiveRecord::Migration[7.1]
  def up
    drop_table :participant_outcomes
  end

  def down
    create_table :participant_outcomes, id: :uuid, default: -> { "gen_random_uuid()" } do |t|
      t.string   :state, null: false
      t.date     :completion_date, null: false
      t.uuid     :participant_declaration_id, null: false
      t.datetime :created_at, null: false
      t.datetime :updated_at, null: false
      t.boolean  :qualified_teachers_api_request_successful
      t.datetime :sent_to_qualified_teachers_api_at

      t.index :created_at, name: "index_participant_outcomes_on_created_at"
      t.index :participant_declaration_id, name: "index_declaration"
      t.index :sent_to_qualified_teachers_api_at, name: "index_participant_outcomes_on_sent_to_qualified_teachers_api_at"
      t.index :state, name: "index_participant_outcomes_on_state"
    end
  end
end
