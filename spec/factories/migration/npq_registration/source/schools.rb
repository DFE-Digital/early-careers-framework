# frozen_string_literal: true

FactoryBot.define do
  factory :npq_reg_source_school, class: Migration::NPQRegistration::Source::School do
    name { Faker::University.name }
    urn { Faker::Number.unique.decimal_part(digits: 7).to_s }
  end
end
