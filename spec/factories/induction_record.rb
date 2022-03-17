# frozen_string_literal: true

FactoryBot.define do
  factory :induction_record do
    induction_programme
    participant_profile { create(:ect_participant_profile) }
    schedule { create(:ecf_schedule) }
    start_date { Date.new(2021, 1, 9) }
  end
end
