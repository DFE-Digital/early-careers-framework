# frozen_string_literal: true

module Participants
  module Withdraw
    class ECF < Base
      include Participants::ECF

      validates :reason, "withdrawn/ecf": true
    end
  end
end
