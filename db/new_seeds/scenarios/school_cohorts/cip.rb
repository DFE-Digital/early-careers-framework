# frozen_string_literal: true

module NewSeeds
  module Scenarios
    module SchoolCohorts
      # Creates a CIP school cohort for the given cohort and the given school or a fresh new one.
      class Cip
        attr_reader :school_cohort

        def initialize(cohort:, school: nil)
          @cohort = cohort
          @school = school
        end

        def build
          @school_cohort = FactoryBot.create(:seed_school_cohort, :cip, school:, cohort:)

          self
        end

        def with_programme(**args)
          add_programme(**args)

          self
        end

        # Adds a CIP induction programme to the school cohort.
        # Optionally links it to the provided core_induction_programme or a fresh new one,
        #   unless core_induction_programme: :none received. Default: create a new one.
        # Optionally sets it as the default induction programme of the school cohort. Default: true.
        # Optionally sets the core induction programme as the default for the school cohort. Default: true.
        def add_programme(core_induction_programme: nil,
                          default_induction_programme: true,
                          default_core_induction_programme: true)
          NewSeeds::Scenarios::InductionProgrammes::Cip
            .new(school_cohort:)
            .build(default_induction_programme:)
            .with_core_induction_programme(core_induction_programme:, default_core_induction_programme:)
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
