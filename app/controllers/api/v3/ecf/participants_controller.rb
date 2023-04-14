# frozen_string_literal: true

require "csv"

module Api
  module V3
    module ECF
      class ParticipantsController < V1::ECFParticipantsController
        include ApiOrderable

        # Returns a list of ECF participants
        # Providers can see their ECF participants and their ECF enrolments via this endpoint
        #
        # GET /api/v3/participants/ecf?filter[cohort]=2021,2022
        #
        def index
          render json: serializer_class.new(paginate(participants), params: { cpd_lead_provider: current_user }).serializable_hash.to_json
        end

      private

        def serializer_class
          Api::V3::ECF::ParticipantSerializer
        end

        def participants
          @participants ||= ecf_participant_query.participants.order(sort_params(params, model: User))
        end

        def ecf_participant_params
          params
            .with_defaults({ filter: { cohort: "", updated_since: "" } })
            .permit(:id, :sort, filter: %i[cohort updated_since])
        end

        def ecf_participant_query
          Api::V3::ECF::ParticipantsQuery.new(
            lead_provider:,
            params: ecf_participant_params,
          )
        end
      end
    end
  end
end
