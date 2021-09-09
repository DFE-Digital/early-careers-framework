# frozen_string_literal: true

module Participants
  module Resume
    class NPQ < ::Participants::Base
      include Participants::NPQ
      include ValidateAndChangeState
    end
  end
end
