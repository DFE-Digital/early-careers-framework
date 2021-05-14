# frozen_string_literal: true

class CreateParticipantRecords < ActiveRecord::Migration[6.1]
  def change
    create_table :participation_records, id: :uuid do |t|
      t.timestamps
      t.references :early_career_teacher_profile, null: false, foreign_key: true
      t.string :state, null: false, default: "assigned"
    end
  end
end
