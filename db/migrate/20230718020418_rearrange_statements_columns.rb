# frozen_string_literal: true

class RearrangeStatementsColumns < ActiveRecord::Migration[7.0]
  def up
    safety_assured do
      add_column :statements, :tmp_output_fee, :boolean, default: true
      execute <<-SQL
                UPDATE statements
                SET tmp_output_fee = output_fee;
      SQL
      remove_column :statements, :output_fee
      rename_column :statements, :tmp_output_fee, :output_fee

      add_column :statements, :tmp_reconcile_amount, :decimal, default: "0.0", null: false
      execute <<-SQL
                UPDATE statements
                SET tmp_reconcile_amount = reconcile_amount;
      SQL
      remove_column :statements, :reconcile_amount
      rename_column :statements, :tmp_reconcile_amount, :reconcile_amount
    end
  end
end
