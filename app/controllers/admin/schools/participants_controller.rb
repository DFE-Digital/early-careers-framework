# frozen_string_literal: true

module Admin
  class Schools::ParticipantsController < Admin::BaseController
    skip_after_action :verify_authorized
    skip_after_action :verify_policy_scoped

    def index
      # TODO: multiple cohorts CPDRP-204
      @participant_profiles = policy_scope(ParticipantProfile::ECF, policy_scope_class: ParticipantProfilePolicy::Scope)
        .active_record
        .where(school_cohort_id: SchoolCohort.where(school: school, cohort: Cohort.current).select(:id))
        .includes(:user)
        .order("users.full_name")
    end

  private

    def school
      @school ||= School.friendly.find params[:school_id]
    end
  end
end
