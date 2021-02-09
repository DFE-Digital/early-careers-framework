# frozen_string_literal: true

class RemoveEncryptedPasswordFromUser < ActiveRecord::Migration[6.1]
  def change
    remove_column :users, :encrypted_password, type: :string
  end
end
