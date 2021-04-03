# frozen_string_literal: true

class Schools::EstimateParticipantsController < Schools::BaseController
  skip_after_action :verify_authorized
  skip_after_action :verify_policy_scoped
  before_action :set_school_cohort

  def edit
    @school_cohort_form = SchoolCohortForm.new
  end

  def update
    @school_cohort_form = SchoolCohortForm.new(form_params)

    if @school_cohort_form.valid?
      @school_cohort.update!(form_params)
      redirect_to schools_cohort_path(@school_cohort.cohort.start_year)
    else
      render :edit
    end
  end

private

  def set_school_cohort
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
