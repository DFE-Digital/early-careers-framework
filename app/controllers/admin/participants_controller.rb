# frozen_string_literal: true

module Admin
  class ParticipantsController < Admin::BaseController
    skip_after_action :verify_policy_scoped, only: :show
    skip_after_action :verify_authorized, only: :index

    before_action :load_participant, only: :show

    def show; end

    def index
      @participant_profiles = policy_scope(ParticipantProfile)
        .ransack(user_full_name_or_school_name_or_school_urn_cont: params[:query]).result
    end

  private

    def load_participant
      @participant = User.is_ecf_participant.find(params[:id])
      authorize @participant, policy_class: ParticipantPolicy
    end
  end
end
