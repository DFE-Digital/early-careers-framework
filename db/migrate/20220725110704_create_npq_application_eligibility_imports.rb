# frozen_string_literal: true

class CreateNPQApplicationEligibilityImports < ActiveRecord::Migration[6.1]
  def change
    create_table :npq_application_eligibility_imports do |t|
      t.references :user, null: false, foreign_key: true, type: :uuid

      t.string :filename
      t.string :status, default: :pending
      t.integer :updated_records
      t.jsonb :import_errors, default: []

      t.datetime :processed_at

      t.timestamps
    end
  end
end
