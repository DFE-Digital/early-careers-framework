# frozen_string_literal: true

class AddFundingFieldsToNPQProfile < ActiveRecord::Migration[6.1]
  def change
    safety_assured do
      change_table :npq_profiles, bulk: true do |t|
        t.boolean :eligible_for_funding, null: false, default: false
        t.text :funding_choice
      end
    end
  end
end
