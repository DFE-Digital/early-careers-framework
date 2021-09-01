# frozen_string_literal: true

module Participants
  module Defer
    class ECF < ::Participants::Base
      include Participants::ECF
      include StateValidation
      attr_accessor :reason
      validates :reason, presence: true
      validates :reason, "deferred/ecf": true
    end
  end
end
