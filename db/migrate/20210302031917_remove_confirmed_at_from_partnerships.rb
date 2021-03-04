# frozen_string_literal: true

class RemoveConfirmedAtFromPartnerships < ActiveRecord::Migration[6.1]
  def change
    remove_column :partnerships, :confirmed_at, :timestamp
  end
end
