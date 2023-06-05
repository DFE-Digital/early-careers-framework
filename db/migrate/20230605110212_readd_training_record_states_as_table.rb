# frozen_string_literal: true

class ReaddTrainingRecordStatesAsTable < ActiveRecord::Migration[6.1]
  def change
    create_table :training_record_states do |t|
      t.uuid :participant_profile_id, null: false
      t.uuid :school_id
      t.uuid :lead_provider_id
      t.uuid :appropriate_body_id
      t.uuid :delivery_partner_id
      t.datetime :changed_at, null: false
      t.string :validation_state, null: false
      t.string :training_eligibility_state, null: false
      t.string :fip_funding_eligibility_state, null: false
      t.string :mentoring_state, null: false
      t.string :training_state, null: false
      t.string :record_state, null: false

      t.timestamps
    end

    add_index :training_record_states, :participant_profile_id
    add_index :training_record_states, :school_id
    add_index :training_record_states, :lead_provider_id
    add_index :training_record_states, :delivery_partner_id

    add_index :training_record_states, %i[participant_profile_id school_id lead_provider_id appropriate_body_id delivery_partner_id changed_at], unique: true, name: "index_training_record_states_unique_ids"

    add_foreign_key :training_record_states, :participant_profiles, validate: false
    add_foreign_key :training_record_states, :schools, validate: false
    add_foreign_key :training_record_states, :lead_providers, validate: false
    add_foreign_key :training_record_states, :delivery_partners, validate: false
    add_foreign_key :training_record_states, :appropriate_bodies, validate: false
  end
end
