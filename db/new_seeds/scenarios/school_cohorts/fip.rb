# frozen_string_literal: true

module NewSeeds
  module Scenarios
    module SchoolCohorts
      # Creates a FIP school cohort for the given cohort and the given school or a fresh new one.
      class Fip
        attr_reader :school_cohort

        def initialize(cohort:, school: nil)
          @school = school
          @cohort = cohort
        end

        def build
          @school_cohort = FactoryBot.create(:seed_school_cohort, :fip, school:, cohort:)

          self
        end

        def with_programme(**args)
          add_programme(**args)

          self
        end

        # Adds a FIP induction programme to the school cohort.
        # Optionally links it to the provided partnership or a fresh new one with new lead provided and delivery partner
        #   unless partnership: :none received. Default: create a new one.
        # Optionally sets it as the default induction programme of the school cohort. Default: true.
        def add_programme(default_induction_programme: true, partnership: nil)
          NewSeeds::Scenarios::InductionProgrammes::Fip.new(school_cohort:)
                                                       .build(default_induction_programme:)
                                                       .with_partnership(partnership:)
                                                       .induction_programme
        end

      private

        attr_reader :cohort

        def school
          @school ||= FactoryBot.create(:seed_school)
        end
      end
    end
  end
end
