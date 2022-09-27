# frozen_string_literal: true

FactoryBot.define do
  factory :appropriate_body_profile do
    user
    appropriate_body { build(:appropriate_body_local_authority) }
  end
end
