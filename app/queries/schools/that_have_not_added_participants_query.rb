# frozen_string_literal: true

module Schools
  class ThatHaveNotAddedParticipantsQuery < BaseService
    def call
      schools_to_include.where(id: school_cohorts_that_have_not_added_participants.select(:school_id))
    end

    attr_reader :cohort, :school_type_codes

    def initialize(cohort: nil, school_type_codes: [])
      @cohort = cohort
      @school_type_codes = school_type_codes
    end

    def schools_to_include
      scope = School.currently_open.in_england
      return scope if school_type_codes.blank?

      scope.where(school_type_code: school_type_codes)
    end

    def school_cohorts_that_have_not_added_participants
      scope = SchoolCohort
        .where(induction_programme_choice: %w[full_induction_programme core_induction_programme])
        .where.missing(:induction_records)

      return scope if cohort.blank?

      scope.joins(:cohort).where(cohort:)
    end
  end
end
