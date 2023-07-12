# frozen_string_literal: true

module Api
  module V1
    class ProviderOutcomesController < Api::ApiController
      include ApiTokenAuthenticatable
      include ApiPagination

      def index
        participant_declarations_hash = serializer_class.new(paginate(query_scope)).serializable_hash
        render json: participant_declarations_hash.to_json
      end

    private

      def serializer_class
        ParticipantOutcomeSerializer
      end

      def query_scope
        ParticipantOutcomesQuery.new(
          cpd_lead_provider:,
          params: npq_participant_outcome_params,
        ).scope
      end

      def npq_participant_outcome_params
        params
          .with_defaults({ filter: { created_since: "" } })
          .permit(filter: %i[created_since])
      end

      def cpd_lead_provider
        current_user
      end
    end
  end
end
