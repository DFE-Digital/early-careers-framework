# frozen_string_literal: true

module Api
  module V1
    class ParticipantOutcomesController < Api::ApiController
      include ApiTokenAuthenticatable

      def index
        participant_declarations_hash = serializer_class.new(query_scope).serializable_hash
        render json: participant_declarations_hash.to_json
      end

    private

      def serializer_class
        ParticipantOutcomeSerializer
      end

      def query_scope
        ParticipantOutcomes::Index.new(
          cpd_lead_provider:,
        ).scope
      end

      def filter
        params[:filter] ||= {}
      end

      def participant_id_filter
        filter[:participant_id]
      end

      def cpd_lead_provider
        current_user
      end
    end
  end
end
