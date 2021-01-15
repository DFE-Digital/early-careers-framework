# frozen_string_literal: true

class CreateLeadProviderCips < ActiveRecord::Migration[6.1]
  def change
    create_table :lead_provider_cips, id: :uuid do |t|
      t.references :lead_provider, null: false, foreign_key: true, type: :uuid
      t.references :cohort, null: false, foreign_key: true, type: :uuid
      t.references :cip, null: false, foreign_key: true, type: :uuid

      t.timestamps
    end
  end
end
