# frozen_string_literal: true

class AddCohortForeignKeyToStatementsAndContracts < ActiveRecord::Migration[6.1]
  disable_ddl_transaction!

  def change
    add_check_constraint :statements, "cohort_id IS NOT NULL",         name: "statements_cohort_id_null",         validate: false
    add_check_constraint :call_off_contracts, "cohort_id IS NOT NULL", name: "call_off_contracts_cohort_id_null", validate: false
    add_check_constraint :npq_contracts, "cohort_id IS NOT NULL",      name: "npq_contracts_cohort_id_null",      validate: false

    add_foreign_key :statements,         :cohorts, validate: false
    add_foreign_key :call_off_contracts, :cohorts, validate: false
    add_foreign_key :npq_contracts,      :cohorts, validate: false
  end
end
