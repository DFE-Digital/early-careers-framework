# frozen_string_literal: true

FactoryBot.define do
  factory :npq_reg_user, class: NPQRegistration::User do
    email { Faker::Internet.unique.email }
  end
end
