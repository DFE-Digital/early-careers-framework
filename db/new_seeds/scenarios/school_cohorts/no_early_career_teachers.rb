# frozen_string_literal: true

module NewSeeds
  module Scenarios
    module SchoolCohorts
      # Creates a design_your_own school cohort for the given cohort and the given school or a fresh new one.
      class NoEarlyCareerTeachers
        attr_reader :school_cohort

        def initialize(cohort:, school: nil)
          @cohort = cohort
          @school = school
        end

        def build
          @school_cohort = FactoryBot.create(:seed_school_cohort, :no_early_career_teachers, school:, cohort:)

          self
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
