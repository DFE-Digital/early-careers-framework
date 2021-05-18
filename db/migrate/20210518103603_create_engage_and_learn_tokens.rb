# frozen_string_literal: true

class CreateEngageAndLearnTokens < ActiveRecord::Migration[6.1]
  def change
    create_table :engage_and_learn_api_tokens do |t|
      t.string :hashed_token, null: false
      t.datetime :last_used_at
      t.index :hashed_token, unique: true
      t.timestamps
    end
  end
end
