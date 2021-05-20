# frozen_string_literal: true

class CreateParticipantEventsPapertrailVersioningTable < ActiveRecord::Migration[6.1]
  def change
    create_table :participant_events, id: :uuid do |t|
      t.string :item_type, null: false
      t.string :event, null: false
      t.string :whodunnit
      t.json :object
      t.json :object_changes
      t.datetime :created_at
      t.uuid :item_id, null: false
      t.index %i[item_type item_id]
    end
  end
end
