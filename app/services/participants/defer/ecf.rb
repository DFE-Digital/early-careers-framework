# frozen_string_literal: true

module Participants
  module Withdraw
    class ECF < ::Participants::Base
      include Participants::ECF
      include StateValidation

      validates :reason, "deferred/ecf": true

    end
  end
end
