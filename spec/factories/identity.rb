# frozen_string_literal: true

FactoryBot.define do
  factory :identity do
    user
    email { user.email }
    external_identifier { user.id }
    origin { "ecf" }

    trait :npq_origin do
      origin { "npq" }
    end
  end
end
