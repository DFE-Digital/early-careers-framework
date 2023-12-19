# frozen_string_literal: true

FactoryBot.define do
  factory :npq_reg_source_user, class: Migration::NPQRegistration::Source::User do
    email { Faker::Internet.unique.email }
  end
end
