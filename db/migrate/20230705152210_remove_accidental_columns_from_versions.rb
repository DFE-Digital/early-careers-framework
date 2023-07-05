# frozen_string_literal: true

class RemoveAccidentalColumnsFromVersions < ActiveRecord::Migration[6.1]
  def change
    StrongMigrations.disable_check(:remove_column)
    remove_column :versions, "{:null=>false}", :string
    StrongMigrations.enable_check(:remove_column)
  end
end
