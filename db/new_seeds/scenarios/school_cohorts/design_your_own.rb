# frozen_string_literal: true

module NewSeeds
  module Scenarios
    module SchoolCohorts
      # Creates a design_your_own school cohort for the given cohort and the given school or a fresh new one.
      class DesignYourOwn
        attr_reader :school_cohort

        def initialize(cohort:, school: nil)
          @cohort = cohort
          @school = school
        end

        def build
          @school_cohort = FactoryBot.create(:seed_school_cohort, :design_our_own, school:, cohort:)

          self
        end

        def with_programme(**args)
          add_programme(**args)

          self
        end

        # Adds a design your own induction programme to the school cohort.
        # Optionally sets it as the default induction programme of the school cohort. Default: true.
        def add_programme(default_induction_programme: true)
          NewSeeds::Scenarios::InductionProgrammes::DesignYourOwn
            .new(school_cohort:)
            .build(default_induction_programme:)
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
