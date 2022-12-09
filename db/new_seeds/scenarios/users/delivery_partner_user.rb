# frozen_string_literal: true

module NewSeeds
  module Scenarios
    module Users
      class DeliveryPartnerUser
        attr_reader :user, :supplied_delivery_partners, :number

        def initialize(user: nil, delivery_partner: nil, delivery_partners: [], number: 0)
          @user = user
          @supplied_delivery_partners = Array.wrap(delivery_partner) + delivery_partners
          @number = number
        end

        def build
          @user ||= FactoryBot.create(:seed_user)

          generated_delivery_partners = FactoryBot.create_list(:seed_delivery_partner, number)

          [*supplied_delivery_partners, *generated_delivery_partners].map do |delivery_partner|
            FactoryBot.create(:seed_delivery_partner_profile, delivery_partner:, user:)
          end
        end
      end
    end
  end
end
