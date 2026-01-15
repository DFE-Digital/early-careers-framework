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

        def revised_target
          contract.recruitment_target&.*(CallOffContract::DEFAULT_REVISED_RECRUITMENT_TARGET_PERCENTAGE)&.round
        end
      end
    end
  end
end
