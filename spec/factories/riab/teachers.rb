# frozen_string_literal: true

FactoryBot.define do
  factory :riab_teacher, class: "RIAB::Teacher" do
    sequence(:id) { |n| n }

    sequence(:trn, 1_000_000)
    sequence(:trs_first_name) { |n| "First name #{n}" }
    sequence(:trs_last_name) { |n| "Last name #{n}" }

    trait :trs_induction_in_progress do
      trs_induction_status { "InProgress" }
    end
  end
end
