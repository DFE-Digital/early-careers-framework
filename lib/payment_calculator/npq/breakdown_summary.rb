# frozen_string_literal: true

module PaymentCalculator
  module NPQ
    class BreakdownSummary
      CURRENT_PARTICIPANTS = :all
      NOT_PAID             = :not_paid
      ELIGIBLE_AND_PAYABLE = :eligible_or_payable

      class << self
        def call(contract:, aggregations:)
          new(contract: contract).call(aggregations)
        end
      end

      def call(aggregations)
        {
          name: lead_provider.name,
          recruitment_target: recruitment_target,
          participants: aggregations[CURRENT_PARTICIPANTS],
          total_participants_paid: aggregations[ELIGIBLE_AND_PAYABLE],
          total_participants_not_paid: aggregations[NOT_PAID],
          version: contract.version,
          course_identifier: contract.course_identifier,
        }
      end

    private

      attr_accessor :contract

      delegate :recruitment_target, to: :contract

      def initialize(contract:)
        self.contract = contract
      end

      def lead_provider
        contract.npq_lead_provider
      end
    end
  end
end
