# frozen_string_literal: true

class AddCachedValueToStatements < ActiveRecord::Migration[6.1]
  def change
    add_column :statements, :original_value, :decimal, null: true
  end
end
