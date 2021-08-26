# frozen_string_literal: true

class CreateParticipantProfileStates < ActiveRecord::Migration[6.1]
  def change
    create_table :participant_profile_states do |t|
      t.references :participant_profile, null: false, foreign_key: true
      t.text :state, default: "active"
      t.text :reason
      t.timestamps
    end
  end
end
