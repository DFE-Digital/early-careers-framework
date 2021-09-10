# frozen_string_literal: true

class AddVoidingToProfileDeclarations < ActiveRecord::Migration[6.1]
  def change
    add_column :profile_declarations, :voided, :boolean, default: false
  end
end
