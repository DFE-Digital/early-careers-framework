# frozen_string_literal: true

FactoryBot.define do
  factory :npq_contract do
    npq_lead_provider { build(:npq_lead_provider, cpd_lead_provider: build(:cpd_lead_provider, name: "NPQ Contract Test Lead Provider")) }
    version { "1.0" }
    service_fee_percentage { 40 }
    output_payment_percentage { 60 }
    per_participant { 800.00 }
    number_of_payment_periods { 3 }
    recruitment_target { 72 }
    course_identifier { "npq-leading-teaching" }
    service_fee_installments { 19 }
    cohort { Cohort.current || create(:cohort, :current) }
    targeted_delivery_funding_per_participant { 100.0 }
  end

  trait :npq_leading_teaching do
    course_identifier { "npq-leading-teaching" }
    recruitment_target { 72 }
    number_of_payment_periods { 3 }
    service_fee_installments { 19 }
    per_participant { 800.00 }
  end

  trait :npq_leading_behaviour_culture do
    course_identifier { "npq-leading-behaviour-culture" }
    recruitment_target { 72 }
    number_of_payment_periods { 3 }
    per_participant { 810.00 }
    service_fee_installments { 19 }
  end

  trait :npq_leading_teaching_development do
    course_identifier { "npq-leading-teaching-development" }
    recruitment_target { 211 }
    number_of_payment_periods { 3 }
    per_participant { 820.00 }
    service_fee_installments { 19 }
  end

  trait :npq_senior_leadership do
    course_identifier { "npq-senior-leadership" }
    recruitment_target { 205 }
    number_of_payment_periods { 4 }
    per_participant { 830.00 }
    service_fee_installments { 25 }
  end

  trait :npq_headship do
    course_identifier { "npq-headship" }
    recruitment_target { 172 }
    number_of_payment_periods { 4 }
    per_participant { 840.00 }
    service_fee_installments { 31 }
  end

  trait :npq_executive_leadership do
    course_identifier { "npq-executive-leadership" }
    recruitment_target { 26 }
    number_of_payment_periods { 4 }
    per_participant { 850.00 }
    service_fee_installments { 25 }
  end

  trait :with_monthly_service_fee do
    monthly_service_fee { 5432.10 }
  end
end
