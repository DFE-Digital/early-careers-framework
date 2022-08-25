# frozen_string_literal: true

class CreateECFAppropriateBodies < ActiveRecord::Migration[6.1]
  def change
    create_table :ecf_appropriate_bodies do |t|
      t.uuid :appropriate_body_id
      t.string :name
      t.string :body_type

      t.timestamps
    end
  end
end
