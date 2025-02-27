# frozen_string_literal: true

module Api
  module ParticipantDeclarations
    class Index
      RELEVANT_INDUCTION_STATUS = %w[active completed].freeze

      attr_reader :cpd_lead_provider, :updated_since, :participant_id

      def initialize(cpd_lead_provider:, updated_since: nil, participant_id: nil)
        @cpd_lead_provider = cpd_lead_provider
        @updated_since = updated_since
        @participant_id = participant_id
      end

      def scope
        scope = ParticipantDeclaration::ECF.union(
          declarations_scope,
          previous_declarations_scope,
        )

        scope = scope.where("user_id = ?", participant_id) if participant_id.present?
        scope = scope.where("updated_at > ?", updated_since) if updated_since.present?

        scope.order(:created_at)
      end

    private

      def lead_provider
        cpd_lead_provider.lead_provider
      end

      def declarations_scope
        ParticipantDeclaration::ECF
          .for_lead_provider(cpd_lead_provider)
      end

      def previous_declarations_scope
        ParticipantDeclaration::ECF
          .joins(participant_profile: { induction_records: { induction_programme: { partnership: [:lead_provider] } } })
          .where(participant_profile: { induction_records: { induction_programme: { partnerships: { lead_provider: } } } })
          .where(participant_profile: { induction_records: { induction_status: RELEVANT_INDUCTION_STATUS } }) # only want induction records that are the winning latest ones
          .where(state: %w[submitted eligible payable paid])
      end
    end
  end
end
