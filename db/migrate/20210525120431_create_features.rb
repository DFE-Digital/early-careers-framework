# frozen_string_literal: true

class CreateFeatures < ActiveRecord::Migration[6.1]
  def change
    create_table :features do |t|
      t.string :name, null: false
      t.boolean :active, default: false, null: false
      t.timestamps
    end

    add_index :features, :name, unique: true
  end
end
