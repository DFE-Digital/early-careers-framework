# frozen_string_literal: true

class AddVoidingToDeclarations < ActiveRecord::Migration[6.1]
  def change
    add_column :participant_declarations, :voided_at, :datetime
  end
end
