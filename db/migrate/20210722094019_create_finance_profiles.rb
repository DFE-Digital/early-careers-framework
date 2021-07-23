# frozen_string_literal: true

class CreateFinanceProfiles < ActiveRecord::Migration[6.1]
  def change
    create_table :finance_profiles do |t|
      t.references :user, null: false, foreign_key: true, type: :uuid

      t.timestamps
    end
  end
end
