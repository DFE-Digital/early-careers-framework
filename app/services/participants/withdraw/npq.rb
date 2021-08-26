# frozen_string_literal: true

module Participants
  module Withdraw
    class NPQ < Base
      include Participants::NPQ

      validates :reason, "withdrawn/npq": true
    end
  end
end
