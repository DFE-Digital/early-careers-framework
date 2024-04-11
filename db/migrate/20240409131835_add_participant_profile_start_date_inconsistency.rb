# frozen_string_literal: true

class AddParticipantProfileStartDateInconsistency < ActiveRecord::Migration[7.1]
  def change
    create_table :participant_profile_start_date_inconsistencies, id: :uuid do |t|
      t.references :participant_profile, null: false, foreign_key: true, type: :uuid
      t.column :dqt_value, :date
      t.column :participant_value, :date

      t.timestamps
    end
  end
end
