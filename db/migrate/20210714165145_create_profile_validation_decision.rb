# frozen_string_literal: true

class CreateProfileValidationDecision < ActiveRecord::Migration[6.1]
  def change
    create_table :profile_validation_decisions do |t|
      t.references :participant_profile, foreign_key: true, index: true, null: false
      t.string :validation_step, null: false
      t.boolean :approved
      t.text :note

      t.timestamps

      t.index %i[participant_profile_id validation_step], unique: true, name: :unique_validation_step
    end
  end
end
