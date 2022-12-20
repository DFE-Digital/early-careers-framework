# frozen_string_literal: true

FactoryBot.define do
  factory :school_local_authority_district do
    start_year { build(:cohort, :current).start_year }
    local_authority_district
    school

    trait :sparse do
      local_authority_district { build(:local_authority_district, :sparse) }
    end
  end
end
