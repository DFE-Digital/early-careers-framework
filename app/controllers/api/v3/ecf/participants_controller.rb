# frozen_string_literal: true

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

        # Returns a single of ECF participant
        # Providers can see a specific ECF participant and its ECF enrolments via this endpoint
        #
        # GET /api/v3/participants/ecf/:id
        def show
          render json: serializer_class.new(participant, params: { cpd_lead_provider: current_user }).serializable_hash.to_json
        end

      private

        def serializer_class
          Api::V3::ECF::ParticipantSerializer
        end

        def participants
          @participants ||= ecf_participant_query.participants.order(sort_params(params, model: User))
        end

        def participant
          @participant ||= ecf_participant_query.participant
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

        def render_from_service(service, serializer, params: {})
          if service.valid?
            induction_record = service.call
            render json: serializer.new(induction_record.user, params: params.merge(induction_record:)).serializable_hash
          else
            render json: Api::V1::ActiveModelErrorsSerializer.from(service), status: :unprocessable_entity
          end
        end

        def serialized_response_for(service)
          render_from_service(service, serializer_class, params: { cpd_lead_provider: current_user })
        end
      end
    end
  end
end
