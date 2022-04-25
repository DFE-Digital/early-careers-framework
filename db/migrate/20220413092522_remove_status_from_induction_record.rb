# frozen_string_literal: true

class RemoveStatusFromInductionRecord < ActiveRecord::Migration[6.1]
  def change
    safety_assured { remove_column :induction_records, :status, :string, null: false, default: "active", index: true }
  end
end
