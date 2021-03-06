# frozen_string_literal: true

class CreateParticipantProfiles < ActiveRecord::Migration[6.1]
  def change
    create_table :participant_profiles do |t|
      t.string :type, null: false

      t.references :user, foreign_key: true, index: true, null: false
      t.references :school, foreign_key: true, index: true, null: false
      t.references :core_induction_programme, foreign_key: true, index: true, null: true
      t.references :cohort, foreign_key: true, index: true, null: false

      # No foregin key yet - not all records will be present
      t.references :mentor_profile, foreign_key: false, index: true, null: true

      t.boolean :sparsity_uplift, default: false, null: false
      t.boolean :pupil_premium_uplift, default: false, null: false

      t.timestamps
    end
  end
end
