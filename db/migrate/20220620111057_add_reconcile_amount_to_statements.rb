# frozen_string_literal: true

class AddReconcileAmountToStatements < ActiveRecord::Migration[6.1]
  def change
    add_column :statements, :reconcile_amount, :decimal, default: 0, null: false
  end
end
