# frozen_string_literal: true

class CreateCips < ActiveRecord::Migration[6.1]
  def change
    create_table :cips, id: :uuid do |t|
      t.string :name

      t.timestamps
    end
  end
end
