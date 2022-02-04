# frozen_string_literal: true

class DeleteStatementType < ActiveRecord::Migration[6.1]
  def change
    safety_assured { remove_column :participant_declarations, :statement_type, :string }
  end
end
