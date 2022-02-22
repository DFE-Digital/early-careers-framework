# frozen_string_literal: true

class AddTrainingStatusToInductionRecord < ActiveRecord::Migration[6.1]
  def change
    add_column :induction_records, :training_status, :string, default: "active", null: false
  end
end
