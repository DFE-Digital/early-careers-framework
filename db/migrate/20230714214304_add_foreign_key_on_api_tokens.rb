# frozen_string_literal: true

class AddForeignKeyOnApiTokens < ActiveRecord::Migration[6.1]
  def change
    add_foreign_key :api_tokens, :lead_providers, on_delete: :cascade, validate: false
  end
end
