# frozen_string_literal: true

class ValidateContraints < ActiveRecord::Migration[6.1]
  def change
    validate_check_constraint :statements,         name: "statements_cohort_id_null"
    validate_check_constraint :call_off_contracts, name: "call_off_contracts_cohort_id_null"
    validate_check_constraint :npq_contracts,      name: "npq_contracts_cohort_id_null"
  end
end
