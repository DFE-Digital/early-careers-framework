# frozen_string_literal: true

class CreateStatementLineItems < ActiveRecord::Migration[6.1]
  def change
    create_table :statement_line_items do |t|
      t.references :statement
      t.references :participant_declaration

      t.text :state, null: false

      t.timestamps
    end
  end
end
