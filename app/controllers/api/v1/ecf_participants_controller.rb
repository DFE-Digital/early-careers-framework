# frozen_string_literal: true

require "csv"

module Api
  module V1
    class ECFParticipantsController < Api::ApiController
      include ApiTokenAuthenticatable
      include ApiPagination
      include ApiCsv
      include ApiFilter
      include ParticipantActions

      # Returns a list of ECF participants
      # Providers can see their ECF participants and which cohorts they apply to via this endpoint
      #
      # GET /api/v1/participants/ecf?filter[cohort]=2021,2022
      #
      def index
        respond_to do |format|
          format.json do
            render json: serializer_class.new(paginate(induction_records)).serializable_hash.to_json
          end

          format.csv do
            render body: to_csv(serializer_class.new(induction_records).serializable_hash)
          end
        end
      end

      # Returns a specific ECF participant given its ID
      # Providers can see a specific ECF participant and which cohorts it applies to via this endpoint
      #
      # GET /api/v1/participants/ecf/:id
      #
      def show
        render json: serializer_class.new(induction_record).serializable_hash.to_json
      end

    private

      def serializer_class
        ParticipantFromInductionRecordSerializer
      end

      def induction_records
        @induction_records ||= ecf_participant_query.induction_records
      end

      def induction_record
        @induction_record ||= ecf_participant_query.induction_record
      end

      def ecf_participant_params
        params.permit(:id, filter: %i[cohort updated_since])
      end

      def access_scope
        LeadProviderApiToken
          .joins(cpd_lead_provider: [:lead_provider])
      end

      def lead_provider
        current_user.lead_provider
      end

      def ecf_participant_query
        Api::V1::ECF::ParticipantsQuery.new(
          lead_provider:,
          params: ecf_participant_params,
        )
      end
    end
  end
end
