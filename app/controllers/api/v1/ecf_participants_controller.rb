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
            participant_hash = ParticipantSerializer.new(paginate(participant_profiles), params: { lead_provider: }).serializable_hash
            render json: participant_hash.to_json
          end

          format.csv do
            participant_hash = ParticipantSerializer.new(participant_profiles, params: { lead_provider: }).serializable_hash
            render body: to_csv(participant_hash)
          end
        end
      end

    private

      def participant_profiles
        join = InductionRecord
                 .select("induction_records.participant_profile_id, induction_records.updated_at, induction_records.created_at, ROW_NUMBER() OVER (PARTITION BY participant_profiles.participant_identity_id ORDER BY CASE WHEN induction_records.training_status = 'active' THEN 0 ELSE 1 END) AS training_status_precedence")
                 .joins(:participant_profile, :schedule, { induction_programme: { partnership: :lead_provider } })
                 .where(
                   schedule: { cohort_id: with_cohorts.map(&:id) },
                   induction_programme: {
                     partnerships: {
                       lead_provider_id: lead_provider.id,
                       challenged_at: nil,
                       challenge_reason: nil,
                     },
                   },
                 )

        scope = ParticipantProfile
                  .joins(participant_identity: :user)
                  .joins("JOIN (#{join.to_sql}) AS induction_records ON induction_records.participant_profile_id = participant_profiles.id AND induction_records.training_status_precedence = 1")

        if updated_since.present?
          scope.where(users: { updated_at: updated_since.. }).order("users.updated_at ASC")
        else
          scope.order("induction_records.created_at ASC")
        end
      end

      def serialized_response(profile)
        relevant_induction_record = profile.relevant_induction_record(lead_provider:)

        ParticipantFromInductionRecordSerializer
          .new(relevant_induction_record)
          .serializable_hash.to_json
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
