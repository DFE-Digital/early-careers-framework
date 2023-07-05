# frozen_string_literal: true

module Api
  module V3
    class NPQParticipantsQuery
      include Concerns::FilterUpdatedSince

      attr_reader :npq_lead_provider, :params

      def initialize(npq_lead_provider:, params:)
        @npq_lead_provider = npq_lead_provider
        @params = params
      end

      def participants
        scope = npq_lead_provider.npq_participants.includes(:teacher_profile, npq_profiles: [:npq_course, :participant_profile_states, :participant_identity, { schedule: [:cohort], npq_application: [npq_lead_provider: :cpd_lead_provider] }])
        scope = scope.where("users.updated_at > ?", updated_since) if updated_since_filter.present?
        scope = scope.order("npq_profiles.created_at ASC") if params[:sort].blank?
        scope.distinct
      end

      def participant
        npq_lead_provider.npq_participants.find(params[:id])
      end
    end
  end
end
