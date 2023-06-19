# frozen_string_literal: true

module NewSeeds
  module Scenarios
    module LeadProviders
      class LeadProvider
        attr_reader :name, :lead_provider, :delivery_partners, :user

        def initialize(name)
          @name = name
          @delivery_partners = []
        end

        def with_contracted_cohorts(cohorts)
          @cohorts = cohorts

          self
        end

        def with_user
          @with_user = true

          self
        end

        def with_delivery_partner
          @with_delivery_partner = true

          self
        end

        def build
          @lead_provider = FactoryBot.create(:seed_lead_provider, name:, cohorts: @cohorts)

          add_user if @with_user
          add_delivery_partner if @with_delivery_partner

          self
        end

      private

        def add_user
          @user = FactoryBot.create(:seed_lead_provider_profile, :with_user, lead_provider:).user
        end

        def add_delivery_partner
          delivery_partner = FactoryBot.create(:seed_delivery_partner, name: "#{name} Delivery partner")
          @cohorts.each do |cohort|
            FactoryBot.create(
              :seed_provider_relationship,
              delivery_partner:,
              lead_provider:,
              cohort:,
            )
          end

          delivery_partners.push(delivery_partner)
        end
      end
    end
  end
end
