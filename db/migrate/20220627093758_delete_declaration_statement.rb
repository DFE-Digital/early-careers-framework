# frozen_string_literal: true

class DeleteDeclarationStatement < ActiveRecord::Migration[6.1]
  def change
    safety_assured do
      remove_column :participant_declarations, :statement_id, :uuid
    end
  end
end
