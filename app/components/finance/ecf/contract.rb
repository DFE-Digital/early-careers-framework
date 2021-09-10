# frozen_string_literal: true

module Finance
  module ECF
    class Contract < BaseComponent
      include FinanceHelper
      attr_accessor :contract
      delegate :uplift_target, :uplift_amount, :recruitment_target, :set_up_fee, to: :contract

      def name
        contract.lead_provider.name
      end

      def bands
        contract.bands.each_with_index.map do |band, index|
          {
            index: index,
            band: band,
          }
        end
      end

    private

      def initialize(contract:)
        @contract = contract
      end
    end
  end
end
