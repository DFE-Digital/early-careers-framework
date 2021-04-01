# frozen_string_literal: true

class Schools::EstimateParticipantsController < Schools::BaseController
  # who has permissions to view this ?
  skip_after_action :verify_authorized
  skip_after_action :verify_policy_scoped
  before_action :get_school_cohort

  def edit
    @school_cohort_form = SchoolCohortForm.new
  end

  def update
    @school_cohort_form = SchoolCohortForm.new(form_params)

    if @school_cohort_form.valid?
      @school_cohort.update!(form_params)
      redirect_to "/schools/cohorts/2021" # TODO: this needs changing?
    else
      render :edit
    end
  end

private

  def get_school_cohort
    @school_cohort = SchoolCohort.find(params[:id])
  end

  def form_params
    params
      .require(:school_cohort_form)
      .permit(
        :estimated_teacher_count,
        :estimated_mentor_count,
      )
  end
end
