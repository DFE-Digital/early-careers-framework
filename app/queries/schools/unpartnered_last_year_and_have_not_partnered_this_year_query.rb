# frozen_string_literal: true

module Schools
  class UnpartneredLastYearAndHaveNotPartneredThisYearQuery < BaseService
    def call
      schools_to_include
        .where(id: unpartnered_schools_this_cohort)
        .where(id: unpartnered_schools_last_cohort)
        .or(schools_to_include.where(id: schools_that_did_not_choose_fip_last_year))
    end

    attr_reader :cohort, :school_type_codes

    def initialize(cohort:, school_type_codes: [])
      @cohort = cohort
      @school_type_codes = school_type_codes
    end

    def schools_to_include
      scope = School.currently_open.in_england
      return scope if school_type_codes.blank?

      scope.where(school_type_code: school_type_codes)
    end

    def unpartnered_schools_this_cohort
      Schools::UnpartneredQuery.call(cohort:, school_type_codes:)
    end

    def unpartnered_schools_last_cohort
      Schools::UnpartneredQuery.call(cohort: cohort.previous, school_type_codes:)
    end

    def schools_that_did_not_choose_fip_last_year
      School.joins(:school_cohorts)
        .where(school_cohorts: { cohort: cohort.previous })
        .where.not(school_cohorts: { induction_programme_choice: "full_induction_programme" })
    end
  end
end
