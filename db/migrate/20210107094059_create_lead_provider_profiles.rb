# frozen_string_literal: true

class CreateLeadProviderProfiles < ActiveRecord::Migration[6.1]
  def change
    create_table :lead_provider_profiles do |t|
      t.references :user, null: false, foreign_key: true, type: :uuid
      t.references :lead_provider, null: false, foreign_key: true, type: :uuid

      t.timestamps
    end
  end
end
