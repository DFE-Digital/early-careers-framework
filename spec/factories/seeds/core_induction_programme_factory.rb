# frozen_string_literal: true

FactoryBot.define do
  factory(:seed_core_induction_programme, class: "CoreInductionProgramme") do
    name { Faker::Company.name }

    trait(:valid) {}

    after(:build) { |cip| Rails.logger.debug("seeded core induction programme #{cip.name}") }
  end
end
