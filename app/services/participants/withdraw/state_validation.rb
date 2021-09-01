# frozen_string_literal: true

module Participants
  module Withdraw
    module StateValidation
      extend ActiveSupport::Concern
      include ActiveModel::Validations

      included do
        extend StateValidationClassMethods
      end

      module StateValidationClassMethods
        def state_to_transition_to
          :withdrawn
        end

        def states_to_transition_from
          %i[active deferred]
        end
      end
    end
  end
end
