# frozen_string_literal: true

class CreateAppropriateBodies < ActiveRecord::Migration[6.1]
  def change
    create_table :appropriate_bodies do |t|
      t.string :name, null: false
      t.string :body_type, null: false

      t.timestamps
    end

    add_index :appropriate_bodies, %i[body_type name], unique: true
  end
end
