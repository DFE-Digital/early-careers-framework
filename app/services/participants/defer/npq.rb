# frozen_string_literal: true

module Participants
  module Defer
    class NPQ < Base
      include Participants::NPQ
      include ValidateAndChangeState
    end
  end
end
