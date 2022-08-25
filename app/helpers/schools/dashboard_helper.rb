# frozen_string_literal: true

module Schools
  module DashboardHelper
    def manage_ects_and_mentors?(school_cohort)
      school_cohort.full_induction_programme? || school_cohort.core_induction_programme?
    end
  end
end
