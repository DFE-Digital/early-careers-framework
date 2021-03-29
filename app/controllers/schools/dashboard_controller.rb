# frozen_string_literal: true

class Schools::DashboardController < Schools::BaseController
  skip_after_action :verify_authorized
  skip_after_action :verify_policy_scoped

  def show
    @school = current_user.induction_coordinator_profile.schools.first

    @cohorts = [Cohort.current].map do |cohort|
      school_cohort = SchoolCohort.find_by(
        cohort: cohort,
        school: @school,
      )

      {
        cohort: cohort,
        school_cohort: school_cohort,
      }
    end

    # This will need to be updated when more than one cohort is supported
    unless @cohorts[0][:school_cohort]
      redirect_to schools_choose_programme_path
    end
  end
end
