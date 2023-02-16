# frozen_string_literal: true

module Admin
  class Schools::ParticipantsController < Admin::BaseController
    skip_after_action :verify_authorized
    skip_after_action :verify_policy_scoped

    def index
      @participant_profiles = policy_scope(ParticipantProfile, policy_scope_class: ParticipantProfile::ECFPolicy)
        .ecf
        .where(id: InductionRecord.for_school(school).current_or_transferring_in.select(:participant_profile_id))
        .includes(participant_identity: :user)
        .order("users.full_name")
    end

  private

    def school
      @school ||= School.friendly.find params[:school_id]
    end
  end
end
