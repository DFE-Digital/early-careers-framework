module Participants
  module Deferral
    extend ActiveSupport::Concern
    include ActiveModel::Validations

    included do
      validates :reason, "defer/ecf": true
      extend WithdrawalClassMethods
    end

    module WithdrawalClassMethods
      def state_to_transition_to
        "defer"
      end
    end
  end
end
