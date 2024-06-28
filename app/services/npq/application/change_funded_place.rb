# frozen_string_literal: true

module NPQ
  module Application
    class ChangeFundedPlace
      include ActiveModel::Model
      include ActiveModel::Attributes

      attribute :npq_application
      attribute :funded_place

      validates :npq_application, presence: { message: I18n.t("npq_application.missing_npq_application") }
      validate :funded_place_not_nil
      validates :funded_place,
                inclusion: {
                  in: [true, false],
                  message: I18n.t("npq_application.funded_place_required"),
                }
      validate :accepted_application
      validate :eligible_for_funding
      validate :eligible_for_removing_funding_place
      validate :cohort_has_funding_cap

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
        return unless npq_application.profile
        return if funded_place

        errors.add(:npq_application, I18n.t("npq_application.cannot_change_funded_place")) if applicable_declarations.any?
      end

      def applicable_declarations
        npq_application
          .profile
          .participant_declarations
          .where(state: %w[submitted eligible payable paid])
      end

      def funded_place_not_nil
        errors.add(:npq_application, I18n.t("npq_application.missing_funded_place")) if funded_place.nil?
      end

      def cohort_has_funding_cap
        return if errors.any?
        return if funded_place.nil?
        return if npq_contract.funding_cap.to_i.positive?

        errors.add(:npq_application, I18n.t("npq_application.cohort_does_not_accept_capping"))
      end

      def npq_contract
        @npq_contract ||= NPQContract.find_latest_by(
          npq_lead_provider: npq_application.npq_lead_provider,
          npq_course: npq_application.npq_course,
          cohort: npq_application.cohort,
        )
      end
    end
  end
end
