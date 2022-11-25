# frozen_string_literal: true

FactoryBot.define do
  factory(:seed_participant_identity, class: "ParticipantIdentity") do
    email { Faker::Internet.unique.email }

    trait :with_user do
      association(:user, factory: :seed_user)
      email { user.email }
    end
  end
end
