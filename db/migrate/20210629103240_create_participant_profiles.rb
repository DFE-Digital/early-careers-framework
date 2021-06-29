class CreateParticipantProfiles < ActiveRecord::Migration[6.1]
  def change
    create_table :participant_profiles do |t|
      t.string :type, null: false

      t.references :user, foreign_key: true, index: true, null: false
      t.references :school, foreign_key: true, index: true, null: false
      t.references :core_induction_programme, foreign_key: true, index: true, null: false
      t.references :cohort, foreign_key: true, index: true, null: false
      t.references :mentor_profile, foreign_key: true, index: true

      t.boolean :sparsity_uplift, default: false, null: false
      t.boolean :pupil_premium_uplift, default: false, null: false

      t.timestamps
    end
  end
end
