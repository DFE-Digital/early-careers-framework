# frozen_string_literal: true

module Api
  module V1
    class ParticipantDeclarationsController < Api::ApiController
      include ApiTokenAuthenticatable
      before_action :set_paper_trail_whodunnit

      def create
        return head :not_found unless params[:id]

        user = User.find(params[:id])

        # TODO: Switch on declaration type
        # TODO: Confirm that this participant is relevant to this lead provider
        return head :not_modified unless InductParticipant.call({ lead_provider: current_user, early_career_teacher_profile: user.early_career_teacher_profile })

        head :no_content
      end
    end
  end
end
