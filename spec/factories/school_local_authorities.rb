# frozen_string_literal: true

FactoryBot.define do
  factory :school_local_authority do
    start_year { 2021 }
    school
    local_authority
  end
end
