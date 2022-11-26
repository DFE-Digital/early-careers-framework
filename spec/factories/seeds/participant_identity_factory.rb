# frozen_string_literal: true

FactoryBot.define do
  factory(:seed_participant_identity, class: "ParticipantIdentity") do
    email { Faker::Internet.unique.email }
    external_identifier { SecureRandom.uuid }

    trait :with_user do
      association(:user, factory: :seed_user)
      email { user.email }
      external_identifier { user.id }
    end

    after(:build) { |pi| Rails.logger.debug("seeded participant_identity for user #{pi.user.full_name}") }
  end
end
