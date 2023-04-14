# frozen_string_literal: true

module Api
  module V3
    class NPQParticipantsQuery
      attr_reader :npq_lead_provider, :params

      def initialize(npq_lead_provider:, params:)
        @npq_lead_provider = npq_lead_provider
        @params = params
      end

      def participants
        scope = npq_lead_provider.npq_participants.includes(:teacher_profile, npq_profiles: [:npq_course, :participant_profile_states, :participant_identity, { schedule: [:cohort], npq_application: [npq_lead_provider: :cpd_lead_provider] }])
        scope = scope.where("users.updated_at > ?", updated_since) if updated_since.present?
        scope = scope.order("users.updated_at DESC") if params[:sort].blank?
        scope.distinct
      end

      def participant
        npq_lead_provider.npq_participants.find(params[:id])
      end

    private

      def filter
        params[:filter] ||= {}
      end

      def updated_since
        return if filter[:updated_since].blank?

        Time.iso8601(filter[:updated_since])
      rescue ArgumentError
        begin
          Time.iso8601(URI.decode_www_form_component(filter[:updated_since]))
        rescue ArgumentError
          raise Api::Errors::InvalidDatetimeError, I18n.t(:invalid_updated_since_filter)
        end
      end
    end
  end
end
