# frozen_string_literal: true

module Finance
  module Statements
    class Clawbacks < BaseComponent
      include FinanceHelper

      attr_reader :calculator

      delegate :clawbacks_breakdown, :mentor?, :ect?, to: :calculator

      def initialize(calculator:)
        @calculator = calculator
      end

      def title
        if mentor?
          "Mentor clawbacks"
        elsif ect?
          "ECT clawbacks"
        else
          "Clawbacks"
        end
      end
    end
  end
end
