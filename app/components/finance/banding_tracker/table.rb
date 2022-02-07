# frozen_string_literal: true

module Finance
  module BandingTracker
    class Table < BaseComponent
      attr_reader :bands, :paid_aggregator, :payable_aggregator

      def initialize(bands:, paid_aggregator:, payable_aggregator:)
        self.bands              = bands
        self.paid_aggregator    = paid_aggregator
        self.payable_aggregator = payable_aggregator
      end

    private

      attr_writer :bands, :paid_aggregator, :payable_aggregator
    end
  end
end
