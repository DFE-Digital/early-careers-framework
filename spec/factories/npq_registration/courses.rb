# frozen_string_literal: true

FactoryBot.define do
  factory :npq_reg_course, class: NPQRegistration::Course do
    sequence(:name) { |n| "NPQ Course #{n}" }
    identifier { "npq-headship" }
  end
end
