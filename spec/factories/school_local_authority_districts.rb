# frozen_string_literal: true

FactoryBot.define do
  factory :school_local_authority_district do
    start_year { 2021 }
    local_authority_district
    school

    trait :sparse do
      local_authority_district { build(:local_authority_district, :sparse) }
    end
  end
end
