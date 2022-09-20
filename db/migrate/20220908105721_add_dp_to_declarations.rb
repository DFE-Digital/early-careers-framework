# frozen_string_literal: true

class AddDpToDeclarations < ActiveRecord::Migration[6.1]
  disable_ddl_transaction!

  def change
    add_reference :participant_declarations, :delivery_partner, index: { algorithm: :concurrently }
  end
end
