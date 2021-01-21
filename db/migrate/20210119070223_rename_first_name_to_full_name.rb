# frozen_string_literal: true

class RenameFirstNameToFullName < ActiveRecord::Migration[6.1]
  def change
    rename_column :users, :first_name, :full_name
  end
end
