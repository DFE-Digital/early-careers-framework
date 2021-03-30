# frozen_string_literal: true

class Schools::DashboardController < Schools::BaseController
  skip_after_action :verify_authorized
  skip_after_action :verify_policy_scoped

  def show
    @school = current_user.induction_coordinator_profile.schools.first

    @school_cohorts = [Cohort.current].map do |cohort|
      @school.school_cohorts.detect do |school_cohort|
        school_cohort.cohort_id == cohort.id
      end
    end

    # This will need to be updated when more than one cohort is supported
    unless @school_cohorts[0]
      redirect_to schools_choose_programme_path
    end
  end
end
