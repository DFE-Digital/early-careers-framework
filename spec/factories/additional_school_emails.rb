# frozen_string_literal: true

FactoryBot.define do
  factory :additional_school_email do
    school
    email_address { Faker::Internet.email }
  end
end
