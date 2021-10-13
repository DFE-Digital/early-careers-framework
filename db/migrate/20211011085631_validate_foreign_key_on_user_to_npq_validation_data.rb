# frozen_string_literal: true

class ValidateForeignKeyOnUserToNPQValidationData < ActiveRecord::Migration[6.1]
  def change
    validate_foreign_key :npq_profiles, :users
  end
end
