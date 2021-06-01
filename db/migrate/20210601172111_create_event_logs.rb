# frozen_string_literal: true

class CreateEventLogs < ActiveRecord::Migration[6.1]
  def change
    create_table :event_logs, id: false do |t|
      t.references :owner, polymorphic: true, index: true
      t.string :event, null: false
      t.json :data, default: {}
      t.timestamps
    end
  end
end
