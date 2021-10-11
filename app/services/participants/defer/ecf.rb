# frozen_string_literal: true

module Participants
  module Defer
    class ECF < Base
      class << self
        def reasons
          %w[
            bereavement
            long-term-sickness
            parental-leave
            career-break
            other
          ].freeze
        end
      end
      include Participants::ECF
      include ValidateAndChangeState
    end
  end
end
