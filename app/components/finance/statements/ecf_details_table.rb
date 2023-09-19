# frozen_string_literal: true

module Finance
  module Statements
    class ECFDetailsTable < BaseComponent
      include FinanceHelper

      attr_accessor :statement

      def initialize(statement:)
        @statement = statement
        @calculator = Finance::ECF::StatementCalculator.new(statement: @statement)
      end
    end
  end
end
