# frozen_string_literal: true

namespace(:anonymous_seed_generator) do
  desc "Dump partnerships to new seed files"
  task(dump_partnerships: :environment) do |t|
    headers = %i[id school_id lead_provider_id cohort_id delivery_partner_id challenged_at challenge_reason challenge_deadline pending report_id relationship]
    rows = Partnership.all.pluck(*headers)

    print_status(t.name, rows.size) do
      dump_to_csv("partnerships", headers:, rows:)
    end
  end
end
