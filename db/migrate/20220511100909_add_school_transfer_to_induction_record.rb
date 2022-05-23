# frozen_string_literal: true

class AddSchoolTransferToInductionRecord < ActiveRecord::Migration[6.1]
  def change
    add_column :induction_records, :school_transfer, :boolean, null: false, default: false
  end
end
