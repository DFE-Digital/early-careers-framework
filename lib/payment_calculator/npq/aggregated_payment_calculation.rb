# frozen_string_literal: true

module PaymentCalculator
  module NPQ
    class AggregatedPaymentCalculation
      class << self
        def call(cpd_lead_provider)
          new(cpd_lead_provider).call
        end
      end

      def call
        cpd_lead_provider.npq_contracts.map do |contract|
          PaymentCalculator::NPQ::PaymentCalculation
            .call(contract:, course_identifier: contract.course_identifier)
        end
      end

    private

      attr_accessor :cpd_lead_provider

      def initialize(cpd_lead_provider)
        self.cpd_lead_provider = cpd_lead_provider
      end
    end
  end
end
