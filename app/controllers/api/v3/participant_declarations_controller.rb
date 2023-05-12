# frozen_string_literal: true

module Api
  module V3
    class ParticipantDeclarationsController < Api::ApiController
      include ApiTokenAuthenticatable
      include ApiPagination
      include ApiFilter

      # Returns a list of participant declarations
      #
      # GET /api/v3/participant-declarations?filter[cohort]=2021,2022
      #
      def index
        render json: serializer_class.new(paginate(participant_declarations)).serializable_hash.to_json
      end

    private

      def cpd_lead_provider
        current_user
      end

      def participant_declarations
        @participant_declarations ||= participant_declarations_query.participant_declarations
      end

      def participant_declarations_query
        ParticipantDeclarationsQuery.new(
          cpd_lead_provider:,
          params: permitted_params,
        )
      end

      def permitted_params
        params.permit(:id, filter: %i[cohort participant_id updated_since delivery_partner_id])
      end

      def access_scope
        LeadProviderApiToken.joins(cpd_lead_provider: [:lead_provider])
      end

      def serializer_class
        ParticipantDeclarationSerializer
      end
    end
  end
end
