namespace :one_offs do
  desc "attach all statements to cohort 2021"
  task backfill_statement_cohort: :environment do
    Finance::Statement.update_all(cohort: Cohort.find_by(start_year: 2021))
  end
end
