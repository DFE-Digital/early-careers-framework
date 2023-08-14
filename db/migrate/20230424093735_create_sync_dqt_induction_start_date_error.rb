# frozen_string_literal: true

class CreateSyncDQTInductionStartDateError < ActiveRecord::Migration[6.1]
  def change
    create_table :sync_dqt_induction_start_date_errors, if_not_exists: true do |t|
      t.belongs_to :participant_profile, null: false, foreign_key: true, type: :uuid, index: { name: "dqt_sync_participant_profile_id" }
      t.text :message

      t.timestamps
    end
  end
end
