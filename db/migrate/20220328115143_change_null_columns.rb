# frozen_string_literal: true

class ChangeNullColumns < ActiveRecord::Migration[6.1]
  def change
    safety_assured do
      change_column_null :statements, :cohort_id, false
      remove_check_constraint :statements, name: "statements_cohort_id_null"

      change_column_null :call_off_contracts, :cohort_id, false
      remove_check_constraint :call_off_contracts, name: "call_off_contracts_cohort_id_null"

      change_column_null :npq_contracts, :cohort_id, false
      remove_check_constraint :npq_contracts, name: "npq_contracts_cohort_id_null"
    end
  end
end
