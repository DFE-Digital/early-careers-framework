# frozen_string_literal: true

module NPQ
  module Application
    class ChangeFundedPlace
      include ActiveModel::Model
      include ActiveModel::Attributes

      attribute :npq_application
      attribute :funded_place

      validates :npq_application, presence: { message: I18n.t("npq_application.missing_npq_application") }
      validate :accepted_application
      validate :eligible_for_funding
      validate :eligible_for_removing_funding_place

      def call
        return npq_application unless FeatureFlag.active?("npq_capping")
        return self unless valid?

        npq_application.update!(funded_place:)

        npq_application
      end

    private

      def accepted_application
        return if npq_application.accepted?

        errors.add(:npq_application, I18n.t("npq_application.cannot_change_funded_status_from_non_accepted"))
      end

      def eligible_for_funding
        return unless funded_place
        return if npq_application.eligible_for_funding?

        errors.add(:npq_application, I18n.t("npq_application.cannot_change_funded_status_non_eligible"))
      end

      def eligible_for_removing_funding_place
        return if funded_place

        errors.add(:npq_application, I18n.t("npq_application.cannot_change_funded_place")) if applicable_declarations.any?
      end

      def applicable_declarations
        npq_application
          .profile
          .participant_declarations
          .where(state: %w[voided awaiting_clawback clawed_back])
      end
    end
  end
end
