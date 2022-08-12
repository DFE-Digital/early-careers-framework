# frozen_string_literal: true

module Finance
  class ChangeLeadProviderApprovalStatusForm
    include ActiveModel::Model
    include ActiveModel::Attributes

    attribute :npq_application
    attribute :change_status_to_pending

    validates :change_status_to_pending, inclusion: { in: %w[yes no] }

    delegate :profile,
             to: :npq_application

    def save
      return false unless valid?
      return true if change_status_to_pending == "no"

      unless ::NPQ::ChangeToPending.call(npq_application:)
        errors.add(:change_status_to_pending, npq_application.errors[:lead_provider_approval_status].first)
        return false
      end

      true
    end
  end
end
