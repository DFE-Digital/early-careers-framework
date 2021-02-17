# frozen_string_literal: true

FactoryBot.define do
  factory :district_sparsity do
    start_year { 2021 }
    local_authority_district
  end
end
