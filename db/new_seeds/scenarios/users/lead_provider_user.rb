# frozen_string_literal: true

module NewSeeds
  module Scenarios
    module Users
      class LeadProviderUser
        attr_reader :user, :new_user_attributes, :lead_provider

        def initialize(user: nil, lead_provider: nil, full_name: nil, email: nil)
          @user = user
          @new_user_attributes = { full_name:, email: }.compact
          @lead_provider = lead_provider || LeadProvider.all.sample
        end

        def build
          lead_provider_user = user || FactoryBot.create(:seed_user, **new_user_attributes)

          FactoryBot.create(:seed_lead_provider_profile, user: lead_provider_user, lead_provider:)

          self
        end

        def add_delivery_partners
          delivery_partner = DeliveryPartner.order(Arel.sql("RANDOM()")).first

          Cohort.all.each do |cohort|
            FactoryBot.create(
              :seed_provider_relationship,
              lead_provider:,
              delivery_partner:,
              cohort:,
            )
          end
        end
      end
    end
  end
end
