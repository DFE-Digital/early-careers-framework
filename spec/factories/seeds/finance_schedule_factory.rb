# frozen_string_literal: true

FactoryBot.define do
  factory(:seed_finance_schedule, class: "Finance::Schedule") do
    schedule_identifier { "#{Faker::Lorem.word} #{Faker::Alphanumeric.alpha(number: 5).upcase}" }
    name { Faker::Lorem.words(number: 2) }

    trait(:with_cohort) do
      association(:cohort, factory: :seed_cohort)
    end

    trait(:valid) { with_cohort }

    after(:build) do |sf|
      Rails.logger.debug("seeded finance schedule #{sf.schedule_identifier}")
    end
  end
end
