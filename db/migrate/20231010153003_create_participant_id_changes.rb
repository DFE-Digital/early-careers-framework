# frozen_string_literal: true

class CreateParticipantIdChanges < ActiveRecord::Migration[7.0]
  def change
    create_table :participant_id_changes do |t|
      t.references :user, null: false, foreign_key: true

      t.references :from_participant, null: false, type: :uuid
      t.references :to_participant, null: false, type: :uuid

      t.timestamps
    end
  end
end
