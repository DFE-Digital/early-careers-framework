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
          .includes(:teacher_profile, npq_profiles: [:npq_course, :participant_profile_states, :participant_identity, { schedule: [:cohort], npq_application: [npq_lead_provider: :cpd_lead_provider] }])
          .order(sort_order(default: "npq_profiles.created_at ASC", model: User))
          .distinct
        scope = scope.where("users.updated_at > ?", updated_since) if updated_since_filter.present?
        scope = scope.where(npq_profiles: { training_status: }) if training_status.present?
        scope
      end

      def participant
        npq_lead_provider.npq_participants.find(params[:id])
      end
    end
  end
end
