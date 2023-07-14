# frozen_string_literal: true

class CreateFinanceAdjustments < ActiveRecord::Migration[7.0]
  def change
    create_table :finance_adjustments do |t|
      t.references :statement, null: false, foreign_key: true
      t.string :payment_type, null: false
      t.decimal :amount, default: 0.0, null: false

      t.timestamps
    end
  end
end
