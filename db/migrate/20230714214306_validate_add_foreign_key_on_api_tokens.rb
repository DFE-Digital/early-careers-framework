# frozen_string_literal: true

class ValidateAddForeignKeyOnApiTokens < ActiveRecord::Migration[7.0]
  def change
    validate_foreign_key :api_tokens, :lead_providers
  end
end
