# frozen_string_literal: true

module Api
  module V1
    module DataStudio
      class ParticipantDeclarationsController < Api::ApiController
        include ApiTokenAuthenticatable

        def index
          render json: { data: json_data }
        end

      private

        def json_data
          ParticipantDeclaration
            .joins(:cpd_lead_provider)
            .group(:cpd_lead_provider_id, "cpd_lead_providers.name")
            .count
            .map do |(lead_provider_id, lead_provider_name), count|
            {
              id: lead_provider_id,
              type: :lead_provider_participant_declarations,
              attributes: {
                lead_provider_name: lead_provider_name,
                count: count,
              },
            }
          end
        end

        def access_scope
          ApiToken.where(private_api_access: true)
        end
      end
    end
  end
end
