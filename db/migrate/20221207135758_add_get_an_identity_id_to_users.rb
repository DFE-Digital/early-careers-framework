# frozen_string_literal: true

class AddGetAnIdentityIdToUsers < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :get_an_identity_id, :string
  end
end
