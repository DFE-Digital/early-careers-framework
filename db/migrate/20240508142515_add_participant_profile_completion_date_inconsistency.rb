# frozen_string_literal: true

class AddParticipantProfileCompletionDateInconsistency < ActiveRecord::Migration[7.1]
  def change
    create_table :participant_profile_completion_date_inconsistencies, id: :uuid do |t|
      t.references :participant_profile, null: false, foreign_key: true, type: :uuid, index: { unique: true }
      t.column :dqt_value, :date
      t.column :participant_value, :date

      t.timestamps
    end
  end
end
