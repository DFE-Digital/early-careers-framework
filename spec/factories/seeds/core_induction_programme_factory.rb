# frozen_string_literal: true

FactoryBot.define do
  factory(:seed_core_induction_programme, class: "CoreInductionProgramme") do
    name { ["Ambition Institute", "Education Development Trust", "Teach First", "UCL Institute of Education"].sample }

    trait(:valid) {}

    after(:build) { |cip| Rails.logger.debug("seeded core induction programme #{cip.name}") }
  end
end
