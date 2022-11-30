# frozen_string_literal: true

module Api
  module V1
    class ParticipantOutcomesQuery
      attr_reader :cpd_lead_provider

      def initialize(cpd_lead_provider:)
        @cpd_lead_provider = cpd_lead_provider
      end

      def scope
        ParticipantOutcome::NPQ
          .joins(:participant_declaration)
          .order(:created_at)
          .merge(declarations_scope)
      end

    private

      def declarations_scope
        ParticipantDeclaration.for_lead_provider(cpd_lead_provider)
      end
    end
  end
end
