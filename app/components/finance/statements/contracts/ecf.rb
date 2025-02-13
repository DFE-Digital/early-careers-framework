# frozen_string_literal: true

module Finance
  module Statements
    module Contracts
      class ECF < BaseComponent
        include FinanceHelper

        attr_accessor :contract

        delegate :uplift_target, :uplift_amount, :recruitment_target,
                 :revised_target, :set_up_fee, :bands,
                 to: :contract

        def initialize(contract:)
          @contract = contract
        end

        def name
          contract.lead_provider.name
        end
      end
    end
  end
end
