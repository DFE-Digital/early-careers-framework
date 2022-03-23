# frozen_string_literal: true

namespace :one_offs do
  desc "attach all statements to cohort 2021"
  task backfill_statement_cohort: :environment do
    Finance::Statement.update_all(cohort_id: Cohort.find_by(start_year: 2021).id)
  end

  desc "attach all contracts to cohort 2021"
  task backfill_contract_cohort: :environment do
    CallOffContract.update_all(cohort_id: Cohort.find_by(start_year: 2021).id)
    NPQContract.update_all(cohort_id: Cohort.find_by(start_year: 2021).id)
  end
end
