# frozen_string_literal: true

class EstimateParticipantsController < Schools::BaseController
  # who has permissions to view this ?
  # skip_after_action :verify_authorized
  # skip_after_action :verify_policy_scoped

  def show
    # will this show the current attributes?
    @school_cohort_form = SchoolCohortForm.new
  end

  def create
    @school_cohort_form = SchoolCohortForm.new(cohort_estimates)

    if @school_cohort_form.valid?
      school_cohort.update!(cohort_estimates)
      redirect_to # TODO
    else
      render :show
    end
  end

private

  def school_cohort
    @school_cohort ||= begin
      # TODO: Register and Partner 262: Figure out how to update current year
      cohort = Cohort.find_by(start_year: 2021) # or params[:id]
      school = current_user.induction_coordinator_profile.schools.first
      SchoolCohort.find_or_create_by!(cohort: cohort, school: school) # or find_by
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
