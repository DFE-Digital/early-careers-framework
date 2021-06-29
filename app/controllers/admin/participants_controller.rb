# frozen_string_literal: true

module Admin
  class ParticipantsController < Admin::BaseController
    skip_after_action :verify_policy_scoped, only: :show

    before_action :load_participant, only: :show

    def show; end

  private

    def load_participant
      @participant_profile = ParticipantProfile.find_by!(user_id: params[:id])
      authorize @participant_profile, policy_class: ParticipantPolicy
    end
  end
end
