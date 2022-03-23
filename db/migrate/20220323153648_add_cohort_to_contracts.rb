# frozen_string_literal: true

class AddCohortToContracts < ActiveRecord::Migration[6.1]
  disable_ddl_transaction!

  def change
    add_reference :call_off_contracts, :cohort, index: { algorithm: :concurrently }
    add_reference :npq_contracts, :cohort, index: { algorithm: :concurrently }
  end
end
