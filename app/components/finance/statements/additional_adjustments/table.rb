# frozen_string_literal: true

module Finance
  module Statements
    module AdditionalAdjustments
      class Table < BaseComponent
        include FinanceHelper

        attr_accessor :statement

        def initialize(statement:)
          @statement = statement
        end

        delegate :adjustments, :adjustment_editable?,
                to: :statement

        def total_amount
          adjustments.sum(&:amount)
        end
      end
    end
  end
end
