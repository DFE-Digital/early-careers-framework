# frozen_string_literal: true

FactoryBot.define do
  factory :lead_provider do
    name  { "Lead Provider" }
    cohorts { Cohort.all }
  end
end
