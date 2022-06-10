# frozen_string_literal: true

class AddUniqueIndexToStatementLineItems < ActiveRecord::Migration[6.1]
  def change
    safety_assured do
      remove_index :statement_line_items, :statement_id
      remove_index :statement_line_items, :participant_declaration_id

      add_index :statement_line_items, %i[statement_id participant_declaration_id state], unique: true, name: :unique_statement_declaration_state
      add_index :statement_line_items, %i[participant_declaration_id statement_id state], unique: true, name: :unique_declaration_statement_state
    end
  end
end
