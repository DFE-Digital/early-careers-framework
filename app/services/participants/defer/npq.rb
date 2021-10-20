# frozen_string_literal: true

module Participants
  module Defer
    class NPQ < Base
      include Participants::NPQ
      extend DeferralReasons
      include ValidateAndChangeState
    end
  end
end
