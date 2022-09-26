# frozen_string_literal: true

namespace(:anonymous_seed_generator) do
  desc "Dump cohorts to new seed files"
  task(dump_cohorts: :environment) do |t|
    headers = %i[id start_year registration_start_date registration_start_date]
    rows = Cohort.all.pluck(*headers)

    print_status(t.name, rows.size) do
      dump_to_csv("cohorts", headers:, rows:)
    end
  end
end
