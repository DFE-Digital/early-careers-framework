# frozen_string_literal: true

module PaymentCalculator
  module ECF
    class BreakdownSummary
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
          revised_target: revised_target,
          ects: aggregations[:ects],
          mentors: aggregations[:mentors],
          participants: aggregations[:all],
          ineligible_participants: aggregations[:ineligible],
        }
      end

    private

      attr_accessor :contract

      delegate :recruitment_target, :revised_target, to: :contract

      def initialize(contract:)
        self.contract = contract
      end

      def lead_provider
        contract.lead_provider
      end
    end
  end
end
