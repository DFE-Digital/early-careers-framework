# frozen_string_literal: true

class AddUserDeclarationIntegrity < ActiveRecord::Migration[6.1]
  def change
    add_foreign_key :participant_declarations, :users, validate: false
  end
end
