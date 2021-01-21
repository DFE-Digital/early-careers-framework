# frozen_string_literal: true

class RemoveLastNameFromUsers < ActiveRecord::Migration[6.1]
  def change
    remove_column :users, :last_name, if_exists: true
  end
end
