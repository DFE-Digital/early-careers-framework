# frozen_string_literal: true

module NewSeeds
  module Scenarios
    module LeadProviders
      class LeadProvider
        attr_reader :name, :lead_provider, :delivery_partners, :user, :cohorts

        delegate :cpd_lead_provider, to: :lead_provider

        def initialize(cohorts: [], name: nil)
          @name = name
          @cohorts = cohorts
          @delivery_partners = {}
        end

        def build
          @lead_provider ||= FactoryBot.create(:seed_lead_provider, :with_cpd_lead_provider, name:, cohorts: @cohorts)

          self
        end

        def with_user
          add_user

          self
        end

        def add_user
          @user = FactoryBot.create(:seed_lead_provider_profile, :with_user, lead_provider:).user
        end

        def with_delivery_partner(**delivery_partner_args)
          add_delivery_partner(**delivery_partner_args)

          self
        end

        def add_delivery_partner(name: "#{@name} Delivery partner", cohorts: @cohorts)
          delivery_partner = FactoryBot.create(:seed_delivery_partner, name:)
          cohorts.each { |cohort| add_provider_relationship(cohort, delivery_partner) }

          delivery_partner
        end

        def delivery_partner
          delivery_partners.values.first
        end

      private

        def add_provider_relationship(cohort, delivery_partner)
          raise ArgumentError, "Cohort cannot be nil for a provider relationship" if cohort.nil?

          FactoryBot.create(:seed_provider_relationship, cohort:, lead_provider:, delivery_partner:)
          delivery_partners[cohort.start_year] = delivery_partner
        end
      end
    end
  end
end
