# frozen_string_literal: true

module NewSeeds
  module Scenarios
    module InductionProgrammes
      # Creates a FIP induction programme to the given school cohort.
      # Optionally links it to the provided partnership or a fresh new one with new lead provided and delivery partner
      #   unless partnership: :none received. Default: create a new one.
      # Optionally sets it as the default induction programme of the school cohort. Default: true.
      class Fip
        attr_reader :induction_programme

        def initialize(school_cohort:, partnership: nil)
          @school_cohort = school_cohort
          @partnership = partnership
        end

        def build(default_induction_programme: true)
          tap do
            @induction_programme = FactoryBot.create(:seed_induction_programme, :fip, school_cohort:, partnership:)
            set_default_induction_programme! if default_induction_programme
          end
        end

      private

        attr_reader :school_cohort

        delegate :cohort, :school, to: :school_cohort

        def delivery_partner
          @delivery_partner ||= FactoryBot.create(:seed_delivery_partner)
        end

        def lead_provider
          @lead_provider ||= FactoryBot.create(:seed_lead_provider)
        end

        def partnership
          return if with_no_partnership?

          @partnership ||= FactoryBot.create(:seed_partnership, cohort:, school:, delivery_partner:, lead_provider:)
        end

        def set_default_induction_programme!
          school_cohort.update!(default_induction_programme: induction_programme)
        end

        def with_no_partnership?
          @with_no_partnership ||= @partnership == :none
        end
      end
    end
  end
end
