# frozen_string_literal: true

class CreateSyncDqtInductionStartDateError < ActiveRecord::Migration[6.1]
  def change
    create_table :sync_dqt_induction_start_date_errors, id: false do |t|
      t.references :participant_profile, null: false, primary_key: true, foreign_key: true, type: :uuid, index: { name: "dqt_sync_participant_profile_id" }
      t.text :error_message
      t.timestamps
    end
  end
end
