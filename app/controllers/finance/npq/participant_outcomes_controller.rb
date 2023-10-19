# frozen_string_literal: true

module Finance
  module NPQ
    class ParticipantOutcomesController < BaseController
      def resend
        participant_outcome.resend!
        redirect_to finance_participant_path(participant_outcome.participant_declaration.participant_profile_id)
      end

    private

      def participant_outcome
        @participant_outcome ||= ParticipantOutcome::NPQ.includes(:participant_declaration).find(params[:participant_outcome_id])
      end
    end
  end
end
