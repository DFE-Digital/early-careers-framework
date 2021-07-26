# frozen_string_literal: true

module Admin
  class Schools::ParticipantsController < Admin::BaseController
    skip_after_action :verify_authorized
    skip_after_action :verify_policy_scoped

    def index
      @participant_profiles = policy_scope(ParticipantProfile::ECF, policy_scope_class: ParticipantProfilePolicy::Scope)
        .where(school_cohort_id: SchoolCohort.where(school: school).select(:id))
        .includes(:user)
        .order("users.full_name")
    end

  private

    def school
      @school ||= School.friendly.find params[:school_id]
    end
  end
end
