# frozen_string_literal: true

FactoryBot.define do
  factory :induction_record do
    schedule { create(:ecf_schedule) }
    start_date { Date.new(2021, 1, 9) }
  end
end
