# frozen_string_literal: true

module Finance
  module ECF
    class ContractBandRow < BaseComponent
      include FinanceHelper

      private

      attr_reader :band, :index
      delegate :min, :max, :per_participant, to: :band

      def initialize(contract_band_row:)
        @band = contract_band_row[:band]
        @index = contract_band_row[:index]
      end
    end
  end
end
