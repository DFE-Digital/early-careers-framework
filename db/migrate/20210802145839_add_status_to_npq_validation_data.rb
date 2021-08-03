# frozen_string_literal: true

class AddStatusToNPQValidationData < ActiveRecord::Migration[6.1]
  def change
    add_column :npq_profiles, :status, :text, null: false, default: "pending"
  end
end
