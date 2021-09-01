module Participants
  module Withdrawal
    extend ActiveSupport::Concern
    include ActiveModel::Validations

    included do
      extend WithdrawalClassMethods
    end

    module WithdrawalClassMethods
      def state_to_transition_to
        "withdraw"
      end
    end
  end
end
