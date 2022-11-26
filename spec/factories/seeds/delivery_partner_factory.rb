# frozen_string_literal: true

FactoryBot.define do
  factory(:seed_delivery_partner, class: "DeliveryPartner") do
    name { Faker::Company.name }

    after(:build) { |dp| Rails.logger.debug("seeded delivery partner #{dp.name}") }
  end
end
