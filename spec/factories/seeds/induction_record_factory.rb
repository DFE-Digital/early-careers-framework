# frozen_string_literal: true

FactoryBot.define do
  factory(:seed_induction_record, class: "InductionRecord") do
    start_date { 6.months.ago }
    schedule { Finance::Schedule::ECF.default }

    trait(:with_participant_profile) { association(:participant_profile, factory: %i[seed_ect_participant_profile valid]) }
    trait(:with_induction_programme) { association(:induction_programme, factory: %i[seed_induction_programme valid]) }
    trait(:with_schedule) { association(:schedule, factory: %i[seed_finance_schedule valid]) }

    trait(:valid) do
      with_schedule
      with_participant_profile
      with_induction_programme
    end

    after(:build) do |ir|
      if ir.user.present?
        Rails.logger.debug("seeded induction_record for #{ir.user.full_name}")
      else
        Rails.logger.debug("seeded incomplete induction record")
      end
    end
  end
end
