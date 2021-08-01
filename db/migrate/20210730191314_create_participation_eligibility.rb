# frozen_string_literal: true

class CreateParticipationEligibility < ActiveRecord::Migration[6.1]
  def change
    create_table :participation_eligibilities, id: :uuid do |t|
      t.references :participant_profile, index: true, foreign_key: true
      t.boolean :qts
      t.boolean :active_flags
      t.boolean :previous_participation
      t.boolean :previous_induction
      t.timestamps
    end
  end
end
