# frozen_string_literal: true

module Finance
  module ECF
    class Contract < BaseComponent
      include FinanceHelper

      attr_accessor :contract

      delegate :uplift_target, :uplift_amount, :recruitment_target, :revised_target, :set_up_fee, to: :contract

      def initialize(contract:)
        @contract = contract
      end

      def name
        contract.lead_provider.name
      end

      def bands
        contract.bands.each_with_index.map do |band, index|
          {
            index:,
            band:,
          }
        end
      end

      def include_uplift_fees?
        !contract.uplift_amount.nil?
      end
    end
  end
end
