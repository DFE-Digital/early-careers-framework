# frozen_string_literal: true

module Finance
  module Statements
    module Contracts
      class ECF < BaseComponent
        include FinanceHelper

        attr_accessor :contract

        delegate :uplift_target, :uplift_amount, :recruitment_target,
                 :set_up_fee, :bands, to: :contract

        def initialize(contract:)
          @contract = contract
        end

        def name
          contract.lead_provider.name
        end

        def revised_target
          contract.recruitment_target&.*(CallOffContract::DEFAULT_REVISED_RECRUITMENT_TARGET_PERCENTAGE)&.round
        end
      end
    end
  end
end
