# frozen_string_literal: true

module Participants
  module Defer
    class ECF < Base
      class << self
        def reasons
          %w[
            parental-leave
            adoption
            bereavement
            long-term-sickness
          ].freeze
        end
      end

      include Participants::ECF
      include ValidateAndChangeState
    end
  end
end
