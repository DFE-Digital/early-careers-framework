# frozen_string_literal: true

module Schools
  class ThatHaveNotEngagedQuery < BaseService
    def call
      schools_to_include.merge(schools_that_have_not_engaged)
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

    def schools_that_have_not_engaged
      School.where.not(id: SchoolCohort.where(cohort:).select(:school_id))
    end
  end
end
