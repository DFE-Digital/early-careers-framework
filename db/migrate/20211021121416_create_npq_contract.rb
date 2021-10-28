# frozen_string_literal: true

class CreateNPQContract < ActiveRecord::Migration[6.1]
  def change
    create_table :npq_contracts do |t|
      t.jsonb "raw"
      t.string :version, default: "0.0.1"

      t.references :npq_lead_provider, nil: false

      t.integer :recruitment_target, nil: false
      t.string :course_identifier, nil: false

      t.integer :service_fee_installments, nil: false
      t.integer :service_fee_percentage, default: 40, nil: false

      t.decimal :per_participant, nil: false
      t.integer :number_of_payment_periods, nil: false
      t.integer :output_payment_percentage, default: 60, nil: false
      t.timestamps
    end
  end
end
