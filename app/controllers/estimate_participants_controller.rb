# frozen_string_literal: true

class EstimateParticipantsController < Schools::BaseController
  # who has permissions to view this ?
  # skip_after_action :verify_authorized
  # skip_after_action :verify_policy_scoped

  def edit
    @school_cohort = SchoolCohort.find(params[:school_cohort_id]) # or id
  end

  def update; end

private

  def school_cohort_params
    params.require(:school_cohort).permit(
      :estimated_teacher_count,
      :estimated_mentor_count,
    )
  end
end
