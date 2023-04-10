# frozen_string_literal: true

module Schools
  module DashboardHelper
    def manage_single_cohort_ects_and_mentors?(school_cohort)
      school_cohort.full_induction_programme? || school_cohort.core_induction_programme?
    end

    def actions?(participants)
      participants.orphan_ects.any?
    end

    def ect_count(school_cohorts)
      school_cohorts.sum { |sc| sc.current_induction_records.ects.count }
    end

    def ect_with_no_mentor_count(school_cohorts)
      school_cohorts.sum { |sc| sc.current_induction_records.ects.where(mentor_profile: nil).count }
    end

    def manage_ects_and_mentors?(school_cohorts)
      school_cohorts.any?(&:full_induction_programme?) || school_cohorts.any?(&:core_induction_programme?)
    end

    def mentor_count(school_cohorts)
      school_cohorts.sum { |sc| sc.current_induction_records.mentors.count }
    end
  end
end
