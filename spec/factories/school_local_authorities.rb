# frozen_string_literal: true

FactoryBot.define do
  factory :school_local_authority do
    start_year { build(:cohort, :current).start_year }
    school
    local_authority
  end
end
