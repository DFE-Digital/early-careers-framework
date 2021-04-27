# frozen_string_literal: true

class CreateEvents < ActiveRecord::Migration[6.1]
  def change
    create_table :events, id: :uuid do |t|
      t.timestamps
      t.references :participant, null: false, foreign_key: true
      t.references :lead_provider, null: false, foreign_key: true
      t.string :event_type, null: false
      t.datetime :event_date, null: false
    end
  end
end
