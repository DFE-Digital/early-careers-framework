# frozen_string_literal: true

class AddAccountCreatedToUser < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :account_created, :boolean, default: false
  end
end
