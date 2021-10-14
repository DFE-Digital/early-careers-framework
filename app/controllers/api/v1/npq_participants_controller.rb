# frozen_string_literal: true

module Api
  module V1
    class NPQParticipantsController < Api::ApiController
      include ApiTokenAuthenticatable
      include ApiPagination
      include ApiFilter

      def index
        npq_participant_hash = NPQParticipantSerializer.new(paginate(npq_participants)).serializable_hash
        render json: npq_participant_hash.to_json
      end

    private

      def npq_lead_provider
        current_api_token.cpd_lead_provider.npq_lead_provider
      end

      def npq_participants
        npq_participants = npq_lead_provider.npq_participants
        npq_participants = npq_participants.where("npq_profiles.updated_at > ?", updated_since) if updated_since.present?
        npq_participants.order(:created_at)
        npq_participants
      end

      def access_scope
        LeadProviderApiToken.joins(cpd_lead_provider: [:npq_lead_provider])
      end
    end
  end
end
