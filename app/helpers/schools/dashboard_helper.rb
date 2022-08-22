# frozen_string_literal: true

module Schools
  module DashboardHelper
    def manage_ects_and_mentors?(school_cohort)
      !(school_cohort.school.cip_only? || school_cohort.school_chose_diy?)
    end
  end
end
