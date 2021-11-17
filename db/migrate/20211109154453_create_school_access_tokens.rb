# frozen_string_literal: true

class CreateSchoolAccessTokens < ActiveRecord::Migration[6.1]
  def change
    create_table :school_access_tokens do |t|
      t.references :school, null: false, foreign_key: true
      t.string :token, null: false
      t.string :permitted_actions, array: true, default: []
      t.datetime :expires_at, null: false

      t.timestamps
      t.index :token, unique: true
    end
  end
end
