# frozen_string_literal: true

class TestUnsafeMigration < ActiveRecord::Migration[7.1]
  def change
    remove_column :participant_declarations, :type, :string
  end
end
