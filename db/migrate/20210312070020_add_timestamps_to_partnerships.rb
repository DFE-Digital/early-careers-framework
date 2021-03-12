# frozen_string_literal: true

class AddTimestampsToPartnerships < ActiveRecord::Migration[6.1]
  def change
    change_table :partnerships, bulk: true do |t|
      t.timestamp :accepted_at
      t.timestamp :rejected_at
    end
  end
end
