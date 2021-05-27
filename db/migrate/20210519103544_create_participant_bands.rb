# frozen_string_literal: true

class CreateParticipantBands < ActiveRecord::Migration[6.1]
  def change
    create_table :participant_bands, id: :uuid do |t|
      t.references :call_off_contract, null: false, foreign_key: true, type: :uuid
      t.integer :min
      t.integer :max
      t.decimal :per_participant

      t.timestamps
    end
  end
end
