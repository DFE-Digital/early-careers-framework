# frozen_string_literal: true

module Admin
  module NPQ
    module Applications
      class UpdateEligibleForFundingRelatedInformation
        attr_reader :npq_application, :eligible_for_funding_updated_by, :eligible_for_funding_updated_at

        def initialize(npq_application, eligible_for_funding_updated_by:, eligible_for_funding_updated_at:)
          @npq_application = npq_application
          @eligible_for_funding_updated_by = eligible_for_funding_updated_by
          @eligible_for_funding_updated_at = eligible_for_funding_updated_at
        end

        def call
          return unless eligible_for_funding_updated_by&.admin?

          npq_application.update!(eligible_for_funding_updated_by: eligible_for_funding_updated_by.id, eligible_for_funding_updated_at:)
        end
      end
    end
  end
end
