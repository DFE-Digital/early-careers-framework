# frozen_string_literal: true

class InductionProgramme::EstimatesController < InductionProgramme::BaseController
  def show
    @school_cohort_form = SchoolCohortForm.new
  end

  def create
    @school_cohort_form = SchoolCohortForm.new(cohort_estimates)

    if @school_cohort_form.valid?
      school_cohort.update!(cohort_estimates)
      redirect_to helpers.profile_dashboard_url(current_user)
    else
      render :show
    end
  end

private

  def school_cohort
    @school_cohort ||= begin
      # TODO: Register and Partner 262: Figure out how to update current year
      cohort = Cohort.find_by(start_year: 2021)
      school = current_user.induction_coordinator_profile.schools.first
      SchoolCohort.find_or_create_by!(cohort: cohort, school: school)
    end
  end

  def cohort_estimates
    params
      .require(:school_cohort_form)
      .permit(
        :estimated_teacher_count,
        :estimated_mentor_count,
      )
  end
end
