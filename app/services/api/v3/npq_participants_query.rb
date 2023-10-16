# frozen_string_literal: true

module Api
  module V3
    class NPQParticipantsQuery
      include Api::Concerns::FilterUpdatedSince
      include Api::Concerns::FilterTrainingStatus
      include Concerns::Orderable

      attr_reader :npq_lead_provider, :params

      def initialize(npq_lead_provider:, params:)
        @npq_lead_provider = npq_lead_provider
        @params = params
      end

      def participants
        scope = npq_lead_provider
          .npq_participants
          .includes(:teacher_profile, :participant_id_changes, npq_profiles: [:npq_course, :participant_profile_states, :participant_identity, { schedule: [:cohort], npq_application: [npq_lead_provider: :cpd_lead_provider] }])
          .order(sort_order(default: "npq_profiles.created_at ASC", model: User))
          .distinct
        scope = scope.where("users.updated_at > ?", updated_since) if updated_since_filter.present?
        scope = scope.where(npq_profiles: { training_status: }) if training_status.present?
        scope = scope.where(participant_id_changes: { from_participant_id: }) if from_participant_id.present?
        scope
      end

      def participant
        npq_lead_provider.npq_participants.find(params[:id])
      end

    private

      def from_participant_id
        filter[:from_participant_id].to_s
      end
    end
  end
end
