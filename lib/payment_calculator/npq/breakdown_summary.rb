# frozen_string_literal: true

module PaymentCalculator
  module NPQ
    class BreakdownSummary
      ALL                  = :all
      SUBMITTED            = :submitted
      ELIGIBLE_AND_PAYABLE = :eligible_and_payable

      class << self
        def call(contract:, aggregations:, event_type: :started)
          new(contract: contract).call(aggregations: aggregations, event_type: event_type)
        end
      end

      def call(aggregations:, event_type: :started)
        {
          name: lead_provider.name,
          declaration: event_type,
          recruitment_target: recruitment_target,
          participants: aggregations[ALL],
          total_participants_paid: aggregations[ELIGIBLE_AND_PAYABLE],
          total_participants_not_paid: aggregations[SUBMITTED],
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
