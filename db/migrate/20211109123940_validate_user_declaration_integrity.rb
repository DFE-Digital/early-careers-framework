# frozen_string_literal: true

class ValidateUserDeclarationIntegrity < ActiveRecord::Migration[6.1]
  def change
    validate_foreign_key :participant_declarations, :users
  end
end
