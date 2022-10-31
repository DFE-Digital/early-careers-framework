# frozen_string_literal: true

module NPQ
  class RejectApplication
    include ActiveModel::Model
    include ActiveModel::Attributes
    include ActiveModel::Validations::Callbacks

    attribute :npq_application

    validates :npq_application, presence: { message: I18n.t("npq_application.missing_npq_application") }
    validate :not_already_rejected
    validate :cannot_change_from_accepted

    def call
      return self unless valid?

      npq_application.update!(lead_provider_approval_status: "rejected")
      npq_application
    end

  private

    def not_already_rejected
      return if npq_application.blank?

      errors.add(:npq_application, I18n.t("npq_application.has_already_been_rejected")) if npq_application.rejected?
    end

    def cannot_change_from_accepted
      return if npq_application.blank?

      errors.add(:npq_application, I18n.t("npq_application.cannot_change_from_accepted")) if npq_application.accepted?
    end
  end
end
