# frozen_string_literal: true

FactoryBot.define do
  factory(:seed_induction_record, class: "InductionRecord") do
    start_date { 6.months.ago }
    schedule { Finance::Schedule.first }

    trait(:with_participant_profile) { association(:participant_profile, factory: :seed_participant_profile) }
    trait(:with_induction_programme) { association(:induction_programme, factory: :seed_induction_programme) }

    after(:build) { |ir| Rails.logger.debug("seeded induction_record for #{ir.user.full_name}") }
  end
end
