# frozen_string_literal: true

module Admin
  class ParticipantsController < Admin::BaseController
    # TODO: probably add this back
    skip_after_action :verify_authorized, only: :show
    skip_after_action :verify_policy_scoped, only: :show

    before_action :load_participant, only: :show

    def show; end

  private

    def load_participant
      @participant = User.is_participant.find(params[:id])
    end
  end
end
