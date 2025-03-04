# frozen_string_literal: true

module Finance
  module Statements
    module DeclarationsBreakdown
      class ECTMentor < BaseComponent
        include FinanceHelper

        attr_accessor :statement, :ect_calculator, :mentor_calculator

        def initialize(statement:, ect_calculator:, mentor_calculator:)
          @statement = statement
          @ect_calculator = ect_calculator
          @mentor_calculator = mentor_calculator
        end

        def ecf_lead_provider
          statement.cpd_lead_provider.lead_provider
        end
      end
    end
  end
end
