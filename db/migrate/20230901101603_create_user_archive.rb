# frozen_string_literal: true

class CreateUserArchive < ActiveRecord::Migration[7.0]
  def change
    create_table :user_archives do |t|
      t.string :user_id, null: false, index: true
      t.string :name, null: false, index: true
      t.string :email, null: false, index: true
      t.string :trn
      t.string :reason, null: false, index: true
      t.jsonb :data
      t.timestamps
    end
  end
end
