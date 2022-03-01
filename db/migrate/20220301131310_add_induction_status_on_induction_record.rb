# frozen_string_literal: true

class AddInductionStatusOnInductionRecord < ActiveRecord::Migration[6.1]
  def change
    add_column :induction_records, :induction_status, :string, default: "active", null: false
  end
end
