# frozen_string_literal: true

class AddTimestampIndicesToInductionRecords < ActiveRecord::Migration[6.1]
  disable_ddl_transaction!

  def change
    add_index :induction_records, :start_date, algorithm: :concurrently
    add_index :induction_records, :end_date, algorithm: :concurrently
    add_index :induction_records, :created_at, algorithm: :concurrently
  end
end
