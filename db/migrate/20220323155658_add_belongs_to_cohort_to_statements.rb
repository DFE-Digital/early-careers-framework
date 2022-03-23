# frozen_string_literal: true

class AddBelongsToCohortToStatements < ActiveRecord::Migration[6.1]
  disable_ddl_transaction!

  def change
    add_reference :statements, :cohort, index: { algorithm: :concurrently }
  end
end
