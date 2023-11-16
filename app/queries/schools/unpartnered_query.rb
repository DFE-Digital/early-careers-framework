# frozen_string_literal: true

module Schools
  class UnpartneredQuery < BaseService
    def call
      schools_to_include
        .merge(schools_that_chose_fip)
        .merge(schools_without_a_partnership)
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

    def schools_without_a_partnership
      School.where.not(id: Partnership.active.where(cohort:).select(:school_id))
    end

    def schools_that_chose_fip
      School.joins(:school_cohorts).merge(SchoolCohort.full_induction_programme.where(cohort:))
    end
  end
end
