# frozen_string_literal: true

module Api
  module V1
    class ParticipantOutcomesController < Api::ApiController
      include ApiTokenAuthenticatable

      def index
        participant_declarations_hash = serializer_class.new(query_scope).serializable_hash
        render json: participant_declarations_hash.to_json
      end

      # Creates a new NPQ participant outcome
      # Providers can create a NPQ participant declaration outcome for a NPQ participant via this endpoint
      #
      # POST /api/v1/participants/npq/:participant_id/outcomes
      #
      def create
        service = ::NPQ::CreateParticipantOutcome.new(action_params)

        render_from_service(service, serializer_class)
      end

    private

      def serializer_class
        ParticipantOutcomeSerializer
      end

      def query_scope
        ParticipantOutcomesQuery.new(
          cpd_lead_provider:,
          participant_external_id:,
        ).scope
      end

      def cpd_lead_provider
        current_user
      end

      def participant_external_id
        params[:participant_id]
      end

      def action_params
        HashWithIndifferentAccess.new(
          cpd_lead_provider:,
          participant_external_id:,
        ).merge(permitted_params["attributes"] || {})
      end

      def permitted_params
        params.require(:data).permit(:type, attributes: %i[course_identifier state completion_date])
      rescue ActionController::ParameterMissing => e
        if e.param == :data
          raise ActionController::BadRequest, I18n.t(:invalid_data_structure)
        else
          raise
        end
      end
    end
  end
end
