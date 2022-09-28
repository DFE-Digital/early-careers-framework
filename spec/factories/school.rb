# frozen_string_literal: true

FactoryBot.define do
  factory :school do
    urn { Faker::Number.unique.decimal_part(digits: 7).to_s }
    name { Faker::University.name }
    postcode { Faker::Address.postcode }
    address_line1 { Faker::Address.street_address }
    domains { [Faker::Internet.domain_name] }
    primary_contact_email { Faker::Internet.email }
    school_status_code { 1 }
    school_type_code { 1 }
    administrative_district_code { "E123" }

    trait :pupil_premium_uplift do
      transient do
        start_year { 2021 }
      end

      pupil_premiums { [build(:pupil_premium, :uplift, start_year:)] }
    end

    trait :sparsity_uplift do
      transient do
        start_year { 2021 }
      end

      pupil_premiums { [build(:pupil_premium, :sparse, start_year:)] }
    end

    trait :pupil_premium_and_sparsity_uplift do
      transient do
        start_year { 2021 }
      end

      pupil_premiums { [build(:pupil_premium, :uplift, :sparse, start_year:)] }
    end

    trait :with_local_authority do
      school_local_authorities { [build(:school_local_authority)] }
    end

    trait :open do
      school_status_code { 1 }
    end

    trait :closed do
      school_status_code { 2 }
    end

    trait :eligible do
      school_status_code { GiasTypes::ELIGIBLE_STATUS_CODES.sample }
      school_type_code   { GiasTypes::ELIGIBLE_TYPE_CODES.sample }
      section_41_approved { true }
      administrative_district_code { "9999" }
    end

    trait :cip_only do
      open
      school_type_code { GiasTypes::CIP_ONLY_TYPE_CODES.sample }
    end

    factory :school_with_consecutive_cohorts do
      transient do
        school_cohorts_count { 5 }
      end

      after :build do |school, evaluator|
        create_list(:school_cohort, evaluator.school_cohorts_count, :consecutive_cohorts, school:)
      end
    end
  end
end
