# frozen_string_literal: true

module NPQ
  class ChangeToPending
    class << self
      def call(npq_application:)
        new(npq_application:).call
      end
    end

    attr_reader :npq_application

    delegate :profile,
             to: :npq_application

    def initialize(npq_application:)
      @npq_application = npq_application
    end

    def call
      return true if npq_application.pending?

      if declarations_exist?
        npq_application.errors.add(:lead_provider_approval_status, :declarations_exist)
        return false
      end

      ActiveRecord::Base.transaction do
        if profile
          profile.participant_profile_states.destroy_all
          profile.participant_declarations.destroy_all
          profile.destroy!
        end
        npq_application.update!(lead_provider_approval_status: "pending")
      end

      true
    end

    def declarations_exist?
      return false unless profile

      profile.participant_declarations.where.not(state: %w[submitted voided ineligible]).any?
    end
  end
end
