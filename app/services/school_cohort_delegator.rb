# frozen_string_literal: true

module SchoolCohortDelegator
  def school
    School.find(school_id)
  end

  def cohort
    Cohort.find(cohort_id)
  end

  delegate :sparsity_uplift?, :pupil_premium_uplift?, to: :school
  delegate :start_year, to: :cohort
end
