# frozen_string_literal: true

class AddUniqueIndexToTrainingRecordStates < ActiveRecord::Migration[6.1]
  disable_ddl_transaction!

  def change
    add_index :training_record_states, %i[participant_profile_id induction_record_id school_id lead_provider_id delivery_partner_id appropriate_body_id], name: :unique_training_record_states, algorithm: :concurrently, unique: true
  end
end
