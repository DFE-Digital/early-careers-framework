# frozen_string_literal: true

require "csv"

module Api
  module V1
    class TestECFParticipantsController < Api::ApiController
      include ApiTokenAuthenticatable
      include ApiPagination
      include ApiCsv
      include ApiFilter
      include Api::ParticipantActions

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

    private

      def access_scope
        LeadProviderApiToken
          .joins(cpd_lead_provider: [:lead_provider])
          .where(private_api_access: true)
      end

      def lead_provider
        current_user.lead_provider
      end

      def induction_records
        scope = InductionRecord
          .where(id: induction_record_ids)
          .includes(participant_profile: %i[
            participant_identity
            user
            cohort
            school
            ecf_participant_eligibility
            ecf_participant_validation_data
            schedule
            teacher_profile
            mentor
          ])

        if updated_since.present?
          scope = scope
            .where(users: { updated_at: updated_since.. })
            .order("users.updated_at, users.id")
        end

        scope.order("users.created_at")
      end

      # this query deals with the following scenario
      # given one profile with 2 induction records
      # we only want to return the latest induction record
      def induction_record_ids
        query = InductionRecord
          .joins(induction_programme: { partnership: :lead_provider })
          .joins(participant_profile: %i[user participant_identity])
          .select("DISTINCT ON (participant_profiles.id) participant_profile_id, induction_records.id")
          .where(induction_programme: { partnerships: { lead_provider: lead_provider } })
          .order("participant_profiles.id", start_date: :desc)
          .to_sql

        ActiveRecord::Base.connection.query_values("SELECT id FROM (#{query}) AS inner_query")
      end
    end
  end
end
