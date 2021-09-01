# frozen_string_literal: true

module Participants
  module Withdraw
    class NPQ < ::Participants::Base
      include Participants::NPQ
      include StateValidation
      attr_accessor :reason
      validates :reason, presence: true
      validates :reason, "withdrawn/npq": true
    end
  end
end
