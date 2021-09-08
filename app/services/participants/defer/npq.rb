# frozen_string_literal: true

module Participants
  module Defer
    class NPQ < ::Participants::Base
      class << self
        def reasons
          %w[
            adoption
          ].freeze
        end
      end

      include Participants::NPQ
      include ValidateAndChangeState
    end
  end
end
