# frozen_string_literal: true

FactoryBot.define do
  factory :privacy_policy do
    sequence(:major_version)
    minor_version { 0 }
    html { Faker::Lorem.paragraphs(number: 4).map { |para| "<p>#{para}</p>\n" }.join }
  end
end
