# frozen_string_literal: true

class CreateMentorsCallOffContracts < ActiveRecord::Migration[7.1]
  def change
    create_table :mentors_call_off_contracts do |t|
      t.belongs_to :lead_provider, null: false, foreign_key: true, type: :uuid, index: true
      t.belongs_to :cohort, null: false, foreign_key: true, type: :uuid, index: true
      t.string :version, null: false, default: "0.0.1"
      t.integer :recruitment_target
      t.decimal :payment_per_participant, default: 1000.00

      t.timestamps
    end
  end
end
