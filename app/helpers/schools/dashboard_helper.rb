# frozen_string_literal: true

module Schools
  module DashboardHelper
    def actions?(participants)
      participants.orphan_mentors.any? ||
        participants.orphan_ects.any? ||
        participants.no_qts.any? ||
        participants.no_induction_start_date.any?
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
