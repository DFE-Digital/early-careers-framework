# frozen_string_literal: true

module Participants
  module Withdraw
    class ECF < Base
      include Participants::ECF
      include ValidateAndChangeState
    end
  end
end
