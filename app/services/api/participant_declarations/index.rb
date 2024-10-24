# frozen_string_literal: true

module Api
  module ParticipantDeclarations
    class Index
      attr_reader :cpd_lead_provider, :updated_since, :participant_id, :type

      def initialize(cpd_lead_provider:, updated_since: nil, participant_id: nil, type: nil)
        @cpd_lead_provider = cpd_lead_provider
        @updated_since = updated_since
        @participant_id = participant_id
        @type = format_type(type)
      end

      def scope
        scope = declaration_class.union(
          declarations_scope,
          previous_declarations_scope,
        )

        scope = scope.where("user_id = ?", participant_id) if participant_id.present?
        scope = scope.where("updated_at > ?", updated_since) if updated_since.present?
        scope = scope.where(type:) if type.present?

        scope.order(:created_at)
      end

    private

      def format_type(type)
        return nil unless Rails.env.migration?

        case type&.downcase&.to_sym
        when :npq
          "ParticipantDeclaration::NPQ"
        when :ecf
          "ParticipantDeclaration::ECF"
        end
      end

      def lead_provider
        cpd_lead_provider.lead_provider
      end

      def declarations_scope
        declaration_class
          .for_lead_provider(cpd_lead_provider)
      end

      def previous_declarations_scope
        declaration_class
          .joins(participant_profile: { induction_records: { induction_programme: { partnership: [:lead_provider] } } })
          .where(participant_profile: { induction_records: { induction_programme: { partnerships: { lead_provider: } } } })
          .where(participant_profile: { induction_records: { induction_status: "active" } }) # only want induction records that are the winning latest ones
          .where(state: %w[submitted eligible payable paid])
      end

      def declaration_class
        if NpqApiEndpoint.disabled?
          ParticipantDeclaration::ECF
        else
          ParticipantDeclaration
        end
      end
    end
  end
end
