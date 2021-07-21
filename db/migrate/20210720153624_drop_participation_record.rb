# frozen_string_literal: true

class DropParticipationRecord < ActiveRecord::Migration[6.1]
  def change
    drop_table :participation_records, id: :uuid do |t|
      t.timestamps
      t.string :state, null: false, default: "assigned"
    end
  end
end
