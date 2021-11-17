# frozen_string_literal: true

FactoryBot.define do
  factory :ecf_participant_validation_data, class: ECFParticipantValidationData do
    participant_profile { create :ecf_participant_profile }

    full_name { Faker::Name.name }
    trn { sprintf("%07i", Random.random_number(9_999_999)) }
    date_of_birth { Faker::Date.birthday }
  end
end
