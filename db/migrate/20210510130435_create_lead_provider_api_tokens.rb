# frozen_string_literal: true

class CreateLeadProviderApiTokens < ActiveRecord::Migration[6.1]
  def change
    create_table :lead_provider_api_tokens do |t|
      t.references :lead_provider, null: false, foreign_key: { on_delete: :cascade }
      t.string :hashed_token, null: false
      t.datetime :last_used_at
      t.index :hashed_token, unique: true
      t.timestamps
    end
  end
end
