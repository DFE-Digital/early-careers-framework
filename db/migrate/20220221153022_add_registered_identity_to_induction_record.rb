# frozen_string_literal: true

class AddRegisteredIdentityToInductionRecord < ActiveRecord::Migration[6.1]
  disable_ddl_transaction!

  def change
    add_reference :induction_records, :registered_identity, null: true, index: { algorithm: :concurrently }
  end
end
