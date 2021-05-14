# frozen_string_literal: true

class AddStartedAtToPartnerships < ActiveRecord::Migration[6.1]
  def change
    add_column :partnerships, :started_at, :datetime
    add_index :partnerships, :started_at
  end
end
