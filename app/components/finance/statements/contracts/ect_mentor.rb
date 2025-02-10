# frozen_string_literal: true

module Finance
  module Statements
    module Contracts
      class ECTMentor < BaseComponent
        include FinanceHelper

        attr_accessor :statement

        delegate :contract, :mentor_contract,
                 to: :statement

        def initialize(statement:)
          @statement = statement
        end
      end
    end
  end
end
