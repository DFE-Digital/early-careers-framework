# frozen_string_literal: true

module Api
  module V1
    class ParticipantOutcomesQuery
      attr_reader :cpd_lead_provider, :participant_external_id, :params

      def initialize(cpd_lead_provider:, participant_external_id: nil, params: {})
        @cpd_lead_provider = cpd_lead_provider
        @participant_external_id = participant_external_id
        @params = params
      end

      def scope
        scope = ParticipantOutcome::NPQ
            .includes(participant_declaration: [participant_profile: [:participant_identity]])
            .joins(:participant_declaration)
            .order(:created_at)
            .merge(declarations_scope)

        scope = filter_by_participant(scope) if participant_external_id.present?
        scope = filter_by_created_since(scope) if created_since.present?
        scope
      end

    private

      def filter
        params[:filter] ||= {}
      end

      def created_since_filter
        filter[:created_since]
      end

      def filter_by_created_since(scope)
        scope.where(created_at: created_since..)
      end

      def filter_by_participant(scope)
        scope.joins(participant_declaration: { participant_profile: :participant_identity })
          .merge(participant_scope)
      end

      def declarations_scope
        ParticipantDeclaration.for_lead_provider(cpd_lead_provider)
      end

      def participant_scope
        ParticipantIdentity.where(user_id: participant_external_id)
      end

      def created_since
        return if created_since_filter.blank?

        Time.iso8601(created_since_filter)
      rescue ArgumentError
        begin
          Time.iso8601(URI.decode_www_form_component(created_since_filter))
        rescue ArgumentError
          raise Api::Errors::InvalidDatetimeError, I18n.t(:invalid_created_since_filter)
        end
      end
    end
  end
end
