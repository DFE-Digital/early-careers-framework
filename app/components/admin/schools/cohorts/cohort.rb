# frozen_string_literal: true

module Admin
  module Schools
    module Cohorts
      class Cohort < BaseComponent
        def initialize(cohort:, school_cohort:)
          @cohort = cohort
          @school_cohort = school_cohort
        end

      private

        attr_reader :cohort, :school_cohort

        def cohort_info
          if school_cohort.nil?
            NoProgramme.new(cohort: cohort)
          elsif school_cohort.core_induction_programme?
            CipInfo.new(school_cohort: school_cohort)
          elsif school_cohort.full_induction_programme?
            FipInfo.new(school_cohort: school_cohort)
          elsif school_cohort.no_early_career_teachers?
            NoEctsInfo.new(cohort: cohort)
          elsif school_cohort.design_our_own?
            DiyInfo.new(cohort: cohort)
          end
        end
      end
    end
  end
end
