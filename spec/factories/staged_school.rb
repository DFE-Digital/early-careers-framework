# frozen_string_literal: true

FactoryBot.define do
  factory :staged_school, class: "DataStage::School" do
    urn { Faker::Number.unique.decimal_part(digits: 6).to_s }
    name { Faker::University.name }
    postcode { Faker::Address.postcode }
    address_line1 { Faker::Address.street_address }
    primary_contact_email { Faker::Internet.email }
    school_status_code { 1 }
    school_status_name { "Open" }
    school_type_code { 1 }
    administrative_district_code { "E123" }
    section_41_approved { false }

    trait :closed do
      school_status_code { 2 }
      school_status_name { "Closed" }
    end
  end
end
