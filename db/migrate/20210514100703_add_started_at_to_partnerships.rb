# frozen_string_literal: true

class AddStartedAtToPartnerships < ActiveRecord::Migration[6.1]
  def change
    add_column :partnerships, :pending, :boolean, null: false, default: false
    add_index :partnerships, :pending
  end
end
