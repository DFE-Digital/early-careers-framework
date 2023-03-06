# frozen_string_literal: true

module Api
  module V1
    class ParticipantOutcomesQuery
      attr_reader :cpd_lead_provider, :participant_external_id

      def initialize(cpd_lead_provider:, participant_external_id: nil)
        @cpd_lead_provider = cpd_lead_provider
        @participant_external_id = participant_external_id
      end

      def scope
        if participant_external_id.nil?
          return ParticipantOutcome::NPQ
            .joins(:participant_declaration)
            .order(:created_at)
            .merge(declarations_scope)
        end

        ParticipantOutcome::NPQ
          .joins(participant_declaration: { participant_profile: :participant_identity })
          .order(:created_at)
          .merge(declarations_scope)
          .merge(participant_scope)
      end

    private

      def declarations_scope
        ParticipantDeclaration.for_lead_provider(cpd_lead_provider)
      end

      def participant_scope
        ParticipantIdentity.where(user_id: participant_external_id)
      end
    end
  end
end
