# frozen_string_literal: true

module Participants
  module Withdraw
    class NPQ < Base
      class << self
        def reasons
          %w[
            left-teaching-profession
            moved-school
            career-break
            other
          ].freeze
        end
      end

      include Participants::NPQ
      include ValidateAndChangeState
    end
  end
end
