# frozen_string_literal: true

FactoryBot.define do
  factory :local_authority do
    code { Faker::Number.unique.decimal_part.to_s }
    name { "Test local authority" }
  end
end
