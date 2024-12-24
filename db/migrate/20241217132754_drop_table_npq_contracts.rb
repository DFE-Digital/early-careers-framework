# frozen_string_literal: true

class DropTableNPQContracts < ActiveRecord::Migration[7.1]
  def up
    drop_table :npq_contracts
  end

  def down
    create_table :npq_contracts, id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
      t.jsonb :raw
      t.string :version, default: "0.0.1"
      t.uuid :npq_lead_provider_id, null: false
      t.integer :recruitment_target
      t.string :course_identifier
      t.integer :service_fee_installments
      t.integer :service_fee_percentage, default: 40
      t.decimal :per_participant
      t.integer :number_of_payment_periods
      t.integer :output_payment_percentage, default: 60
      t.datetime :created_at, null: false
      t.datetime :updated_at, null: false
      t.uuid :cohort_id, null: false
      t.decimal :monthly_service_fee, default: "0.0"
      t.decimal :targeted_delivery_funding_per_participant, default: "100.0"
      t.boolean :special_course, default: false, null: false
      t.integer :funding_cap

      t.index :cohort_id, name: "index_npq_contracts_on_cohort_id"
      t.index :npq_lead_provider_id, name: "index_npq_contracts_on_npq_lead_provider_id"
    end
  end
end
