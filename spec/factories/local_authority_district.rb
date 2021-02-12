# frozen_string_literal: true

FactoryBot.define do
  factory :local_authority_district do
    code { Faker::Number.unique.decimal_part.to_s }
    name { "Test local authority district" }

    trait :sparse do
      district_sparsities { [build(:district_sparsity)] }
    end
  end
end
