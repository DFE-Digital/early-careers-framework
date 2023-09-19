# frozen_string_literal: true

module Finance
  module Statements
    class NPQDetailsTable < BaseComponent
      include FinanceHelper

      attr_accessor :statement

      def initialize(statement:)
        @statement = statement
        @calculator = Finance::NPQ::StatementCalculator.new(statement: @statement)
      end
    end
  end
end
