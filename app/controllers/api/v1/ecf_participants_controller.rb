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

      def index
        respond_to do |format|
          format.json do
            participant_hash = ParticipantFromInductionRecordSerializer.new(paginate(induction_records)).serializable_hash
            render json: participant_hash.to_json
          end

          format.csv do
            participant_hash = ParticipantFromInductionRecordSerializer.new(induction_records).serializable_hash
            render body: to_csv(participant_hash)
          end
        end
      end

      def show
        participant_hash = ParticipantFromInductionRecordSerializer.new(induction_record).serializable_hash

        render json: participant_hash.to_json
      end

    private

      def induction_records
        @induction_records ||= ECFParticipants::Index.new(cpd_lead_provider: current_user, params:).induction_records
      end

      def induction_record
        @induction_record = ECFParticipants::Index.new(cpd_lead_provider: current_user, params:).induction_record.first
      end

      def access_scope
        LeadProviderApiToken
          .joins(cpd_lead_provider: [:lead_provider])
      end

      def lead_provider
        current_user.lead_provider
      end
    end
  end
end
