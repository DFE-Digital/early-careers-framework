# frozen_string_literal: true

module Participants
  module Defer
    class ECF < Base
      include Participants::ECF
      extend DeferralReasons
      include ValidateAndChangeState
    end
  end
end
