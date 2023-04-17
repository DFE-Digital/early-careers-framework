# frozen_string_literal: true

module Api
  module V3
    class NPQParticipantsController < V1::NPQParticipantsController
      include ApiOrderable

    private

      def npq_participants
        @npq_participants ||= npq_participants_query.participants.order(sort_params(params, model: User))
      end

      def npq_participant
        @npq_participant ||= npq_participants_query.participant
      end

      def npq_participants_query
        Api::V3::NPQParticipantsQuery.new(
          npq_lead_provider:,
          params: npq_participant_params,
        )
      end

      def npq_participant_params
        params
          .with_defaults({ sort: "", filter: { updated_since: "" } })
          .permit(:id, :sort, filter: %i[updated_since])
      end

      def serializer_class
        Api::V3::NPQParticipantSerializer
      end
    end
  end
end
