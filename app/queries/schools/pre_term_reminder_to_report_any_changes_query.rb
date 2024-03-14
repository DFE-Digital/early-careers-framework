# frozen_string_literal: true

module Schools
  class PreTermReminderToReportAnyChangesQuery < BaseService
    def call
      schools_to_include.where(id: opted_in_schools_that_ran_fip_or_cip.select(:school_id))
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

    def opted_in_schools_that_ran_fip_or_cip
      School
        .joins(:school_cohorts)
        .merge(SchoolCohort.where(cohort:, induction_programme_choice: %w[full_induction_programme core_induction_programme], opt_out_of_updates: false))
    end
  end
end
