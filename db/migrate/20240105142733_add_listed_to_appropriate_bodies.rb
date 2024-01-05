# frozen_string_literal: true

class AddListedToAppropriateBodies < ActiveRecord::Migration[7.0]
  def change
    add_column :appropriate_bodies, :listed, :boolean, null: false, default: false
  end
end
