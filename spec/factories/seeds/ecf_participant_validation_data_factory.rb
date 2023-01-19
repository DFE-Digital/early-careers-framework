# frozen_string_literal: true

FactoryBot.define do
  factory(:seed_ecf_participant_validation_data, class: "ECFParticipantValidationData") do
    transient do
      user { FactoryBot.build(:user) }
      extra_initial { Faker::Alphanumeric::ULetters.sample }
    end

    full_name { user.full_name.split.insert(1, "#{extra_initial}.").join(" ") }
    trn { Faker::Number.unique.rand_in_range(10_000, 100_000).to_s }
    date_of_birth { Faker::Date.between(from: 70.years.ago, to: 21.years.ago) }
    nino { SecureRandom.hex }

    trait(:with_participant_profile) do
      association(:participant_profile, factory: %i[seed_ect_participant_profile valid])
    end

    trait(:valid) { with_participant_profile }

    after(:build) do
      Rails.logger.debug("added participant validation data")
    end
  end
end
