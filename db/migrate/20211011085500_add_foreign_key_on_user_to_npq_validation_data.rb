# frozen_string_literal: true

class AddForeignKeyOnUserToNPQValidationData < ActiveRecord::Migration[6.1]
  def change
    add_foreign_key :npq_profiles, :users, null: false, validate: false
  end
end
