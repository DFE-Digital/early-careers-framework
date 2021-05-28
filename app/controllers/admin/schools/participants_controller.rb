# frozen_string_literal: true

module Admin
  class Schools::ParticipantsController < Admin::BaseController
    skip_after_action :verify_authorized
    skip_after_action :verify_policy_scoped
    before_action :set_school

    def index
      @participants = User.order(:full_name)
        .includes(early_career_teacher_profile: %i[cohort school], mentor_profile: %i[cohort school])
        .is_participant
        .in_school(@school.id)
    end

  private

    def set_school
      @school = School.find params[:school_id]
    end
  end
end
