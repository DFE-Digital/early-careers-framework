module Participants
  module Defer
    module StateValidation
      extend ActiveSupport::Concern
      include ActiveModel::Validations

      included do
        extend StateValidationClassMethods
      end

      module StateValidationClassMethods
        def state_to_transition_to
          :deferred
        end

        def states_to_transition_from
          %i[active]
        end
      end

    end
  end
end
