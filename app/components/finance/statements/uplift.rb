# frozen_string_literal: true

module Finance
  module Statements
    class Uplift < BaseComponent
      include FinanceHelper

      attr_reader :calculator

      def initialize(calculator:)
        @calculator = calculator
      end

      delegate :uplift_additions_count, :uplift_fee_per_declaration, :uplift_payment,
               to: :calculator
    end
  end
end
