# frozen_string_literal: true

FactoryBot.define do
  factory :district_sparsity do
    start_year { build(:cohort, :current).start_year }
    local_authority_district
  end
end
