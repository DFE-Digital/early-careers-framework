# frozen_string_literal: true

module NPQ
  class ChangeToPending
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
      return if npq_application.pending?

      npq_application.update!(lead_provider_approval_status: "pending")
    end
  end
end
