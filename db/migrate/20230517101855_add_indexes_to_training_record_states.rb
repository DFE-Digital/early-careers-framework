# frozen_string_literal: true

class AddIndexesToTrainingRecordStates < ActiveRecord::Migration[6.1]
  disable_ddl_transaction!

  def change
    add_index :training_record_states, :participant_profile_id, name: :participant_profile_state_index, algorithm: :concurrently

    add_index :training_record_states, %i[participant_profile_id induction_record_id], name: :participant_profile_induction_record_state_index, algorithm: :concurrently
    add_index :training_record_states, %i[participant_profile_id school_id], name: :participant_profile_school_state_index, algorithm: :concurrently
    add_index :training_record_states, %i[participant_profile_id lead_provider_id], name: :participant_profile_lead_provider_state_index, algorithm: :concurrently
    add_index :training_record_states, %i[participant_profile_id delivery_partner_id], name: :participant_profile_delivery_partner_state_index, algorithm: :concurrently
    add_index :training_record_states, %i[participant_profile_id appropriate_body_id], name: :participant_profile_appropriate_body_state_index, algorithm: :concurrently

    add_index :training_record_states, :validation_state, name: :validation_state_index, algorithm: :concurrently
    add_index :training_record_states, :training_eligibility_state, name: :training_eligibility_state_index, algorithm: :concurrently
    add_index :training_record_states, :fip_funding_eligibility_state, name: :fip_funding_eligibility_state_index, algorithm: :concurrently
    add_index :training_record_states, :training_state, name: :training_state_index, algorithm: :concurrently
    add_index :training_record_states, :record_state, name: :record_state_index, algorithm: :concurrently
  end
end
