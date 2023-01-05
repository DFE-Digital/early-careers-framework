# frozen_string_literal: true

FactoryBot.define do
  factory :seed_appropriate_body, class: "AppropriateBody" do
    transient { location { Faker::Address.city } }

    sequence(:name) { |n| "#{location} appropriate body #{n}" }

    body_type { "local_authority" }

    trait(:teaching_school_hub) { body_type { "teaching_school_hub" } }
    trait(:national) { body_type { "national" } }
    trait(:valid) {}

    after(:build) { |ab| Rails.logger.debug("seeded appropriate body #{ab.name}") }
  end
end
