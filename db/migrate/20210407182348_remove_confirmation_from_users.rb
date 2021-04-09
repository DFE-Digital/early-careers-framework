# frozen_string_literal: true

class RemoveConfirmationFromUsers < ActiveRecord::Migration[6.1]
  def change
    change_table :users, bulk: true do
      remove_column :users, :confirmed_at, :datetime
      remove_column :users, :confirmation_sent_at, :datetime
      remove_column :users, :confirmation_token, :string
    end
  end
end
