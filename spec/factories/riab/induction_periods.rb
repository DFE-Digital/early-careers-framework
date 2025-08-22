# frozen_string_literal: true

FactoryBot.define do
  factory :riab_induction_period, class: "RIAB::InductionPeriod" do
    sequence(:id) { |n| n }

    teacher factory: :riab_teacher

    appropriate_body_id { 1 }

    started_on { 1.year.ago }
    finished_on { 1.month.ago }
    number_of_terms { 1 }
    induction_programme { "fip" }
    training_programme { "provider_led" }

    trait :ongoing do
      finished_on { nil }
      number_of_terms { nil }
    end

    trait :pass do
      outcome { :pass }
    end

    trait :fail do
      outcome { :fail }
    end

    trait(:cip) { induction_programme { "cip" } }
    trait(:diy) { induction_programme { "diy" } }
  end
end
