# frozen_string_literal: true

module Schools
  class WithEctsWithNoMentorQuery < BaseService
    def call
      schools_to_include.where(id: school_cohorts_that_have_ects_without_mentors.select(:school_id))
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

    def school_cohorts_that_have_ects_without_mentors
      scope = SchoolCohort
        .joins(induction_records: [participant_profile: :ecf_participant_eligibility])
        .where(induction_programme_choice: %w[full_induction_programme core_induction_programme])
        .where.not(ecf_participant_eligibility: { status: :ineligible })
        .merge(InductionRecord.ects.active.training_status_active.where(mentor_profile_id: nil))

      return scope if cohort.blank?

      scope.joins(:cohort).where(cohort:)
    end
  end
end
