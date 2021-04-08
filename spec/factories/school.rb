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
      pupil_premiums { [build(:pupil_premium, :eligible)] }
    end

    trait :sparsity_uplift do
      school_local_authority_districts { [build(:school_local_authority_district, :sparse)] }
    end

    trait :with_local_authority do
      school_local_authorities { [build(:school_local_authority)] }
    end
  end
end
