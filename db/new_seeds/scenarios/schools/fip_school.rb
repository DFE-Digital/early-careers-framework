# frozen_string_literal: true

module NewSeeds
  module Scenarios
    module Schools
      class FipSchool

        attr_reader :name, :urn, :cohort, :school_attributes, :school, :school_cohort, :partnership, :induction_programme

        def initialize(name: nil, urn: nil, cohort: nil)
          @name = name
          @urn = urn
          @cohort = cohort || FactoryBot.create(:seed_cohort)
          @school_attributes = { name:, urn: }.compact
        end

        def build()
          @school = FactoryBot.create(:seed_school, **school_attributes)
          @partnership = FactoryBot.create(:seed_partnership, :with_lead_provider, :with_delivery_partner, cohort:, school:)

          school_cohort_attrs = {
            induction_programme_choice: "full_induction_programme",
            school:,
            cohort:,
          }.compact

          @school_cohort = FactoryBot.create(:seed_school_cohort, **school_cohort_attrs)

          @induction_programme = FactoryBot.create(:seed_induction_programme, :fip, school_cohort:, partnership:)

          school_cohort.update!(default_induction_programme: induction_programme)

          self
        end
      end
    end
  end
end
