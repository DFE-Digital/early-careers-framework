# frozen_string_literal: true

module Participants
  module Withdraw
    class ECF < ::Participants::Base
      include Participants::ECF

      class << self
        def state_to_transition_to
          :withdraw
        end

        def states_to_transition_from
          [:active, :defer]
        end
      end

      validates :reason, "withdrawn/ecf": true

    end
  end
end
