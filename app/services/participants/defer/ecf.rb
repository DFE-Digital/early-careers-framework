# frozen_string_literal: true

module Participants
  module Defer
    class ECF < ::Participants::Base
      class << self
        def reasons
          %w[
            other
          ].freeze
        end
      end

      include Participants::ECF
      include ValidateAndChange
    end
  end
end
