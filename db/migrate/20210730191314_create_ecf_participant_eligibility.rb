# frozen_string_literal: true

class CreateECFParticipantEligibility < ActiveRecord::Migration[6.1]
  def change
    create_table :ecf_participant_eligibilities, id: :uuid do |t|
      t.references :participant_profile, foreign_key: true, index: { unique: true }
      t.boolean :qts
      t.boolean :active_flags
      t.boolean :previous_participation
      t.boolean :previous_induction
      t.boolean :manually_validated, default: false
      t.string :status, null: false, default: "manual_check"
      t.timestamps
    end
  end
end
