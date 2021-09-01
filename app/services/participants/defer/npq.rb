# frozen_string_literal: true

module Participants
  module Withdraw
    class NPQ < ::Participants::Base
      include Participants::NPQ
      include StateValidation

      validates :reason, "deferred/npq": true
    end
  end
end
