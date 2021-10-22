class CreateNPQContract < ActiveRecord::Migration[6.1]
  def change
    create_table :npq_contracts do |t|
      t.jsonb "raw"
      t.integer :version

      t.references :npq_lead_provider

      t.integer :recruitment_target
      t.string :course_identifier

      t.integer :service_fee_installments
      t.integer :service_fee_percentage, default: 40

      t.decimal :per_participant
      t.integer :number_of_payment_periods
      t.integer :output_payment_percentage, default: 60
      t.timestamps
    end
  end
end
