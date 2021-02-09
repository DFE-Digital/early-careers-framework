# frozen_string_literal: true

class CreateProviderRelationships < ActiveRecord::Migration[6.1]
  def change
    create_table :provider_relationships, id: :uuid do |t|
      t.references :lead_provider, null: false, foreign_key: true, type: :uuid
      t.references :delivery_partner, null: false, foreign_key: true, type: :uuid
      t.references :cohort, null: false, foreign_key: true, type: :uuid
      t.timestamps
    end
  end
end
