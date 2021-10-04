# frozen_string_literal: true

module Participants
  module Defer
    class NPQ < Base
      class << self
        def reasons
          %w[
            other
          ].freeze
        end
      end

      include Participants::NPQ
      include ValidateAndChangeState
    end
  end
end
