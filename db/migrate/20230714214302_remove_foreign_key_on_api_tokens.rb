# frozen_string_literal: true

class RemoveForeignKeyOnApiTokens < ActiveRecord::Migration[6.1]
  def change
    remove_foreign_key :api_tokens, :lead_providers, if_exists: true
  end
end
