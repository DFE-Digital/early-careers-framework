# frozen_string_literal: true

module Api
  module V3
    class NPQParticipantsController < Api::ApiController
      include ApiTokenAuthenticatable
      include ApiPagination
      include ApiFilter
      include ApiOrderable

      # Return±s a list of NPQ participants
      # Providers can see their NPQ participants and their NPQ enrolments via this endpoint
      #
      # GET /api/v3/participants/npq?filter[updated_since]=2022-11-13T11:21:55Z&sort=-updated_at,full_name
      #
      def index
        render json: serializer_class.new(paginate(npq_participants), params: { cpd_lead_provider: current_user }).serializable_hash.to_json
      end

    private

      def npq_lead_provider
        current_api_token.cpd_lead_provider.npq_lead_provider
      end

      def npq_participants
        @npq_participants ||= npq_participants_query.participants.order(sort_params(params, model: User))
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
          .permit(:sort, filter: %i[updated_since])
      end

      def access_scope
        LeadProviderApiToken.joins(cpd_lead_provider: [:npq_lead_provider])
      end

      def serializer_class
        Api::V3::NPQParticipantSerializer
      end
    end
  end
end
