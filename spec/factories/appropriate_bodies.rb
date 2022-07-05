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
  end
end
