# frozen_string_literal: true

module NPQ
  class Reject
    class << self
      def call(npq_application:)
        new(npq_application:).call
      end
    end

    attr_reader :npq_application

    def initialize(npq_application:)
      @npq_application = npq_application
    end

    def call
      if npq_application.rejected?
        npq_application.errors.add(:lead_provider_approval_status, :has_already_been_rejected)
        return false
      end

      if npq_application.accepted?
        npq_application.errors.add(:lead_provider_approval_status, :cannot_change_from_accepted)
        return false
      end

      npq_application.update!(lead_provider_approval_status: "rejected")

      true
    end
  end
end
