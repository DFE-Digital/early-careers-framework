# frozen_string_literal: true

FactoryBot.define do
  factory(:seed_delivery_partner_profile, class: "DeliveryPartnerProfile") do
    trait(:with_user) { association(:user, factory: :seed_user) }
    trait(:with_delivery_partner) { association(:delivery_partner, factory: :seed_delivery_partner) }

    trait(:valid) do
      with_user
      with_delivery_partner
    end

    after(:build) do |dp|
      if dp.user.present? && dp.delivery_partner.present?
        Rails.logger.debug("seeded delivery partner profile for user #{dp.user.full_name} at #{dp.delivery_partner.name}")
      else
        Rails.logger.debug("seeded incomplete delivery partner profile")
      end
    end
  end
end
