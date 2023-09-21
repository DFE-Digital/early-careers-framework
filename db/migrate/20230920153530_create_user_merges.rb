# frozen_string_literal: true

class CreateUserMerges < ActiveRecord::Migration[7.0]
  def change
    create_table :user_merges do |t|
      t.references :from_user, null: false, foreign_key: { to_table: :users }, type: :uuid
      t.references :to_user, null: false, foreign_key: { to_table: :users }, type: :uuid
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
