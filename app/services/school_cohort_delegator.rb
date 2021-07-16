# frozen_string_literal: true

module SchoolCohortDelegator
  delegate :school, to: :school_cohort
  delegate :cohort, to: :school_cohort
  delegate :sparsity_uplift?, :pupil_premium_uplift?, to: :school
  delegate :start_year, to: :cohort
end
