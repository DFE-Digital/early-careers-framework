# frozen_string_literal: true

FactoryBot.define do
  factory :appropriate_body do
    factory :appropriate_body_local_authority do
      sequence :name do |n|
        "Local authority #{n}"
      end
      body_type { "local_authority" }
    end

    factory :appropriate_body_teaching_school_hub do
      sequence :name do |n|
        "Teaching school hub #{n}"
      end
      body_type { "teaching_school_hub" }
    end

    factory :appropriate_body_national_organisation do
      sequence :name do |n|
        "National organisation #{n}"
      end
      body_type { "national" }
    end

    trait :esp do
      name { AppropriateBody::ESP }
      body_type { "national" }
    end

    trait :istip do
      name { AppropriateBody::ISTIP }
      body_type { "national" }
    end

    trait :supports_independent_schools_only do
      listed_for_school_type_codes { GiasTypes::INDEPENDENT_SCHOOLS_TYPE_CODES }
    end

    trait :supports_all_schools do
      listed_for_school_type_codes { GiasTypes::ALL_TYPE_CODES }
    end
  end
end
