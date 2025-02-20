# frozen_string_literal: true

module Finance
  module Statements
    class Adjustments < BaseComponent
      include FinanceHelper

      attr_reader :statement, :calculator

      delegate :clawbacks_breakdown, to: :calculator

      def initialize(statement:, calculator:)
        @statement = statement
        @calculator = calculator
      end
    end
  end
end
