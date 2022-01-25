# frozen_string_literal: true

class AddStatementToDeclarations < ActiveRecord::Migration[6.1]
  disable_ddl_transaction!

  def change
    add_belongs_to :participant_declarations, :statement, polymorphic: true, index: { algorithm: :concurrently }, type: :uuid
  end
end
