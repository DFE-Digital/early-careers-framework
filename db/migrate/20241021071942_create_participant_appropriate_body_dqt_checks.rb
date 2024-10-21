# frozen_string_literal: true

class CreateParticipantAppropriateBodyDQTChecks < ActiveRecord::Migration[7.1]
  def change
    create_table :participant_appropriate_body_dqt_checks do |t|
      t.uuid :participant_profile_id, null: false
      t.string :appropriate_body_name
      t.string :dqt_appropriate_body_name

      t.timestamps
    end
  end
end
