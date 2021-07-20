# frozen_string_literal: true

module Admin
  class Schools::ParticipantsController < Admin::BaseController
    skip_after_action :verify_authorized
    skip_after_action :verify_policy_scoped
    before_action :set_school

    def index
      @participants = @school.active_ecf_participants.order(:full_name).includes(
        early_career_teacher_profile: [:mentor, school_cohort: %i[school cohort]],
        mentor_profile: [school_cohort: %i[school cohort]],
      )
    end

  private

    def set_school
      @school = School.friendly.find params[:school_id]
    end
  end
end
