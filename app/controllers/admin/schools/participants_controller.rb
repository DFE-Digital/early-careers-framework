# frozen_string_literal: true

module Admin
  class Schools::ParticipantsController < Admin::BaseController
    skip_after_action :verify_authorized
    skip_after_action :verify_policy_scoped
    before_action :set_school

    def index
      @participants = @school.participants.order(:full_name)
    end

  private

    def set_school
      @school = School.friendly.find params[:school_id]
    end
  end
end
