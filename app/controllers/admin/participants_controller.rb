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
      @participant_profile = ParticipantProfile.find(params[:id])
      authorize @participant_profile, policy_class: ParticipantProfilePolicy
    end
  end
end
