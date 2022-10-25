# frozen_string_literal: true

FactoryBot.define do
  factory :participant_identity do
    user { create :user }
    email { user.email }
    external_identifier { user.id }
    origin { "ecf" }

    trait :npq_origin do
      origin { "npq" }
    end

    trait :secondary do
      external_identifier { SecureRandom.uuid }
    end
  end
end
