# frozen_string_literal: true

class CreateAnalyticsECFParticipant < ActiveRecord::Migration[6.1]
  def change
    create_table :ecf_participants do |t|
      t.string :user_id
      t.datetime :user_created_at
      t.integer :real_time_attempts
      t.boolean :real_time_success
      t.datetime :validation_submitted_at
      t.boolean :trn_verified
      t.string :school_urn
      t.string :school_name
      t.string :establishment_phase_name
      t.string :participant_type
      t.string :participant_profile_id
      t.string :cohort
      t.string :mentor_id
      t.boolean :nino_entered
      t.boolean :manually_validated
      t.boolean :eligible_for_funding

      t.timestamps
    end

    add_index :ecf_participants, :participant_profile_id
  end
end
