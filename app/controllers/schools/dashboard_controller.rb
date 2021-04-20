# frozen_string_literal: true

class Schools::DashboardController < Schools::BaseController
  skip_after_action :verify_authorized
  skip_after_action :verify_policy_scoped
  before_action :set_school_cohorts

  def show; end

private

  def set_school_cohorts
    @school = current_user.induction_coordinator_profile.schools.first

    cohort_list = [Cohort.current]
    @school_cohorts = @school.school_cohorts.where(cohort: cohort_list)

    # This will need to be updated when more than one cohort is supported
    unless @school_cohorts[0]
      redirect_to advisory_schools_choose_programme_path
    end
  end
end
