# frozen_string_literal: true

class AddStatusToPartnerships < ActiveRecord::Migration[6.1]
  def change
    add_column :partnerships, :status, :string, null: false, default: "pending"
  end
end
