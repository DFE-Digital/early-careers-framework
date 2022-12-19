# frozen_string_literal: true

FactoryBot.define do
  factory(:seed_local_authority, class: "LocalAuthority") do
    code { Faker::Number.unique.decimal_part.to_s }
    name { "#{Faker::Address.city} local authority" }

    trait(:valid) {}

    after(:build) do |la|
      Rails.logger.debug("built local authority #{la.code} / #{la.name}")
    end
  end
end
