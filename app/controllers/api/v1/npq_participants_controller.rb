# frozen_string_literal: true

module Api
  module V1
    class NPQParticipantsController < Api::ApiController
      include ApiTokenAuthenticatable
      include ApiPagination
      include ApiFilter
      include ParticipantActions

      def index
        render json: serializer_class.new(paginate(npq_participants), params: { cpd_lead_provider: current_user }).serializable_hash.to_json
      end

    private

      def serializer_class
        NPQParticipantSerializer
      end

      def serialized_response(participant_profile)
        serializer_class
          .new(participant_profile.user, params: { cpd_lead_provider: current_user })
          .serializable_hash.to_json
      end

      def npq_lead_provider
        current_api_token.cpd_lead_provider.npq_lead_provider
      end

      def npq_participants
        npq_participants = npq_lead_provider.npq_participants
        npq_participants = npq_participants.where("users.updated_at > ?", updated_since) if updated_since.present?
        npq_participants.order(:created_at)
        npq_participants
      end

      def access_scope
        LeadProviderApiToken.joins(cpd_lead_provider: [:npq_lead_provider])
      end
    end
  end
end
