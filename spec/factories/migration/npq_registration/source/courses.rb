# frozen_string_literal: true

FactoryBot.define do
  factory :npq_reg_source_course, class: Migration::NPQRegistration::Source::Course do
    sequence(:name) { |n| "NPQ Course #{n}" }
    identifier { "npq-headship" }
  end
end
