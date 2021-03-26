# frozen_string_literal: true

class Schools::CohortsController < Schools::BaseController
  skip_after_action :verify_authorized
  skip_after_action :verify_policy_scoped

  def show
    @school = current_user.induction_coordinator_profile.schools.first
    @cohort = Cohort.find_by(start_year: params[:id])

    @school_cohort = SchoolCohort.find_by(
      cohort: @cohort,
      school: @school,
    )
  end
end
