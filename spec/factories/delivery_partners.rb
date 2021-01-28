# frozen_string_literal: true

FactoryBot.define do
  factory :delivery_partner do
    name { Faker::Company.name }
  end
end
