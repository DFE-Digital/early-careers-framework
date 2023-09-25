# frozen_string_literal: true

module Finance
  module NPQ
    class ChangeLeadProviderForm
      include ActiveModel::Model
      include ActiveModel::Attributes

      attribute :participant_profile
      attribute :lead_provider_id

      validates :cohort, npq_contract_for_cohort_and_course: true, if: :lead_provider
      validates :lead_provider_id, inclusion: { in: :valid_lead_provider_ids }

      def save
        return false unless valid?
        return true if lead_provider_unchanged?

        Transfers::NPQParticipants.new(
          external_identifier:,
          new_npq_lead_provider_id: lead_provider_id,
          course_identifier:,
        ).call

        true
      end

      def lead_provider_options
        @lead_provider_options ||=
          NPQLeadProvider.name_order.includes(:cohorts).where(cohorts: { id: npq_application.cohort_id }, npq_contracts: { course_identifier: })
      end

      def current_lead_provider
        npq_application.npq_lead_provider
      end

      def change_lead_provider?
        participant_profile.participant_declarations.where(state: %w[submitted eligible payable paid awaiting_clawback clawed_back]).exists?
      end

      def lead_provider
        @lead_provider ||= NPQLeadProvider.find_by(id: lead_provider_id)
      end

      def course_identifier
        npq_application.npq_course.identifier
      end

    private

      delegate :participant_identity, :npq_application, to: :participant_profile
      delegate :cohort, to: :npq_application
      delegate :cpd_lead_provider, to: :npq_lead_provider

      alias_method :npq_lead_provider, :lead_provider

      def valid_lead_provider_ids
        lead_provider_options.pluck(:id)
      end

      def external_identifier
        participant_identity.external_identifier
      end

      def lead_provider_unchanged?
        lead_provider_id == current_lead_provider.id
      end
    end
  end
end
