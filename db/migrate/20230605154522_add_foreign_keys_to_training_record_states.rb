# frozen_string_literal: true

class AddForeignKeysToTrainingRecordStates < ActiveRecord::Migration[6.1]
  def change
    validate_foreign_key :training_record_states, :participant_profiles
    validate_foreign_key :training_record_states, :schools
    validate_foreign_key :training_record_states, :lead_providers
    validate_foreign_key :training_record_states, :delivery_partners
    validate_foreign_key :training_record_states, :appropriate_bodies
  end
end
